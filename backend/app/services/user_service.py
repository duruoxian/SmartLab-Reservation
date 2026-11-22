"""Business rules and transactions for M01."""

import hashlib
import hmac
import re
import secrets
import time
from functools import lru_cache

from sqlalchemy import delete, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core.config import JWT_EXPIRE_SECONDS, LOGIN_FAILURE_LIMIT, LOGIN_LOCK_SECONDS
from app.core.database import SessionLocal, begin_write, initialize_schema
from app.core.exceptions import ApiError, forbidden, unauthorized
from app.core.security import ADMIN, ROLE_NAMES, create_token, hash_password, is_frozen, verify_password
from app.models.entities import AuthSession, DictionaryItem, User
from app.models.schemas import NewAccount, ProfileUpdate, PublicUser
from app.repos import user_repo

_DUMMY_HASH = hash_password(secrets.token_urlsafe(16))


def initialize() -> None:
    initialize_schema()
    with SessionLocal() as db:
        begin_write(db)
        existing = {item.code for item in user_repo.role_items(db)}
        for order, (code, name) in enumerate(ROLE_NAMES.items()):
            if code not in existing:
                db.add(DictionaryItem(type="role", code=code, name=name, sort_order=order))
        db.commit()


def _validate_password(password: str) -> None:
    if not re.search(r"[A-Za-z]", password) or not re.search(r"[0-9]", password):
        raise ApiError(400, "密码须包含英文字母和数字")


def _digest(code: str) -> str:
    return hashlib.sha256(code.encode()).hexdigest()


def _issue_recovery_code(user: User) -> str:
    code = secrets.token_urlsafe(18)
    user.recovery_hash = _digest(code)
    return code


def public_user(user: User) -> dict:
    return PublicUser(
        id=user.id, user_no=user.user_no, name=user.name, role=user.role, college=user.college,
        major=user.major, phone=user.phone, status=user.status, violation_count=user.violation_count,
        frozen_until=user.frozen_until, booking_frozen=is_frozen(user, int(time.time())),
    ).model_dump()


@lru_cache(maxsize=256)
def _cached_user(user_id: int, _minute: int) -> dict | None:
    with SessionLocal() as db:
        user = db.get(User, user_id)
        return public_user(user) if user else None


def get_user(user_id: int) -> dict | None:
    """Cache internal display data for at most 60 seconds."""
    profile = _cached_user(user_id, int(time.monotonic() // 60))
    return profile.copy() if profile is not None else None


def registration_roles(db: Session) -> list[dict]:
    return [{"code": item.code, "name": item.name} for item in user_repo.role_items(db) if item.code != ADMIN]


def create_account(db: Session, form: NewAccount, role: str) -> dict:
    _validate_password(form.password)
    now = int(time.time())
    user = User(
        user_no=form.user_no, name=form.name, role=role, college=form.college, major=form.major,
        phone=form.phone, password_hash=hash_password(form.password), created_at=now,
    )
    recovery_code = _issue_recovery_code(user)
    db.add(user)
    try:
        db.flush()
    except IntegrityError as error:
        db.rollback()
        raise ApiError(409, "该学号或工号已注册") from error
    user_repo.record_operation(db, "register", role, now, actor_id=user.id, target_id=user.id)
    db.commit()
    _cached_user.cache_clear()
    return {"user": public_user(user), "recovery_code": recovery_code}


def _lock_error(until: int, now: int) -> ApiError:
    return ApiError(423, "连续登录失败，账号暂时锁定", {"lock_until": until, "retry_after": until - now})


def _clear_lock(user: User) -> None:
    user.fail_count = 0
    user.lock_until = None


def login(db: Session, user_no: str, password: str) -> dict:
    begin_write(db)
    user = user_repo.find_by_number(db, user_no, lock=True)
    now = int(time.time())
    if user is None:
        verify_password(password, _DUMMY_HASH)
        user_repo.record_operation(db, "login", "invalid_credentials", now)
        db.commit()
        raise unauthorized("学号、工号或密码错误")
    if user.status != "启用":
        user_repo.record_operation(db, "login", "disabled", now, target_id=user.id)
        db.commit()
        raise forbidden("账号已被禁用，请联系管理员")
    if user.lock_until is not None:
        if user.lock_until > now:
            raise _lock_error(user.lock_until, now)
        _clear_lock(user)

    if not verify_password(password, user.password_hash):
        user.fail_count += 1
        if user.fail_count >= LOGIN_FAILURE_LIMIT:
            user.lock_until = now + LOGIN_LOCK_SECONDS
        user_repo.record_operation(db, "login", "locked" if user.lock_until else "invalid_credentials",
                                   now, target_id=user.id)
        db.commit()
        if user.lock_until:
            raise _lock_error(user.lock_until, now)
        raise unauthorized("学号、工号或密码错误")

    _clear_lock(user)
    user_repo.remove_idle_sessions(db, user.id, now - JWT_EXPIRE_SECONDS)
    sid = secrets.token_urlsafe(32)
    db.add(AuthSession(sid=sid, user_id=user.id, last_activity_at=now))
    user_repo.record_operation(db, "login", "success", now, actor_id=user.id, target_id=user.id)
    db.commit()
    return {"token": create_token(user.id, user.role, sid, now), "user": public_user(user)}


def _lock_active_user(db: Session, user_id: int) -> User:
    begin_write(db)
    user = db.get(User, user_id, populate_existing=True, with_for_update=True)
    if user is None:
        raise unauthorized("账号不存在")
    if user.status != "启用":
        raise forbidden("账号已被禁用，请联系管理员")
    return user


def update_profile(db: Session, user_id: int, form: ProfileUpdate) -> dict:
    user = _lock_active_user(db, user_id)
    for field, value in form.model_dump().items():
        setattr(user, field, value)
    user_repo.record_operation(db, "profile_update", "success", int(time.time()), actor_id=user.id, target_id=user.id)
    db.commit()
    _cached_user.cache_clear()
    return public_user(user)


def _replace_password(db: Session, user: User, new_password: str, action: str) -> None:
    user.password_hash = hash_password(new_password)
    _clear_lock(user)
    user_repo.remove_sessions(db, user.id)
    user_repo.record_operation(db, action, "success", int(time.time()), actor_id=user.id, target_id=user.id)
    db.commit()


def reset_password(db: Session, user_no: str, phone: str, code: str, new_password: str) -> None:
    _validate_password(new_password)
    begin_write(db)
    user = user_repo.find_by_number(db, user_no, lock=True)
    if (user is None or user.status != "启用" or user.phone != phone or not user.recovery_hash
            or not hmac.compare_digest(user.recovery_hash, _digest(code))):
        raise ApiError(409, "账号、预留手机号或恢复码不匹配")
    user.recovery_hash = None
    _replace_password(db, user, new_password, "password_reset")


def change_password(db: Session, user_id: int, current_password: str, new_password: str) -> None:
    _validate_password(new_password)
    user = _lock_active_user(db, user_id)
    if not verify_password(current_password, user.password_hash):
        raise ApiError(409, "当前密码不正确")
    _replace_password(db, user, new_password, "password_change")


def renew_recovery_code(db: Session, user_id: int, current_password: str) -> str:
    user = _lock_active_user(db, user_id)
    if not verify_password(current_password, user.password_hash):
        raise ApiError(409, "当前密码不正确")
    code = _issue_recovery_code(user)
    user_repo.record_operation(db, "recovery_code_change", "success", int(time.time()),
                               actor_id=user.id, target_id=user.id)
    db.commit()
    return code


def logout(db: Session, user_id: int, sid: str) -> None:
    db.execute(delete(AuthSession).where(AuthSession.sid == sid, AuthSession.user_id == user_id))
    user_repo.record_operation(db, "logout", "success", int(time.time()), actor_id=user_id, target_id=user_id)
    db.commit()


def admin_list(db: Session, keyword: str, page: int, page_size: int) -> dict:
    accounts = user_repo.list_users(db, keyword.strip(), page, page_size)
    return {"items": [public_user(item) for item in accounts[:page_size]],
            "page": page, "has_more": len(accounts) > page_size}


def change_role(db: Session, actor_id: int, target_id: int, role: str) -> dict:
    if actor_id == target_id:
        raise ApiError(409, "请由另一位管理员调整你的角色")
    begin_write(db)
    accounts = {user.id: user for user in db.scalars(
        select(User).where(User.id.in_([actor_id, target_id])).order_by(User.id)
        .with_for_update().execution_options(populate_existing=True)
    )}
    actor, target = accounts.get(actor_id), accounts.get(target_id)
    if actor is None or actor.role != ADMIN or actor.status != "启用":
        raise forbidden()
    if target is None:
        raise ApiError(404, "用户不存在")
    old_role = target.role
    if old_role != role:
        target.role = role
        user_repo.record_operation(db, "role_change", f"{old_role}->{role}", int(time.time()),
                                   actor_id=actor_id, target_id=target_id)
    db.commit()
    _cached_user.cache_clear()
    return public_user(target)
