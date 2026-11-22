"""PBKDF2, rolling JWT sessions and role dependencies."""

import hashlib
import hmac
import secrets
import time

import jwt
from fastapi import Depends, Request
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import case, update
from sqlalchemy.orm import Session

from app.core.config import JWT_ALGORITHM, JWT_EXPIRE_SECONDS, JWT_SECRET, PBKDF2_ITERATIONS, SALT_BYTES
from app.core.database import get_db
from app.core.exceptions import forbidden, unauthorized
from app.models.entities import AuthSession, User
from app.repos.user_repo import record_operation

_bearer = HTTPBearer(auto_error=False)
TOKEN_HEADER = "X-SmartLab-Token"
ROLE_NAMES = {"student": "学生", "teacher": "教师", "admin": "管理员"}
ADMIN = "admin"
TEACHER = "teacher"
STUDENT = "student"


def hash_password(password: str) -> str:
    salt = secrets.token_hex(SALT_BYTES)
    digest = hashlib.pbkdf2_hmac("sha256", password.encode(), salt.encode("ascii"), PBKDF2_ITERATIONS)
    return salt + digest.hex()


def verify_password(password: str, stored: str) -> bool:
    if len(stored) != SALT_BYTES * 2 + 64:
        return False
    salt, expected = stored[:SALT_BYTES * 2], stored[SALT_BYTES * 2:]
    digest = hashlib.pbkdf2_hmac("sha256", password.encode(), salt.encode("ascii"), PBKDF2_ITERATIONS)
    return hmac.compare_digest(digest.hex(), expected)


def create_token(user_id: int, role: str, sid: str, now: int | None = None) -> str:
    now = int(time.time()) if now is None else now
    return jwt.encode(
        {"user_id": user_id, "role": role, "sid": sid, "iat": now, "exp": now + JWT_EXPIRE_SECONDS},
        JWT_SECRET,
        algorithm=JWT_ALGORITHM,
    )


def decode_token(token: str) -> dict:
    try:
        payload = jwt.decode(
            token, JWT_SECRET, algorithms=[JWT_ALGORITHM],
            options={"require": ["exp", "iat", "user_id", "role", "sid"]},
        )
    except jwt.ExpiredSignatureError as error:
        raise unauthorized("登录已过期，请重新登录") from error
    except jwt.InvalidTokenError as error:
        raise unauthorized("无效的登录凭证") from error
    if type(payload["user_id"]) is not int or not isinstance(payload["sid"], str) or len(payload["sid"]) != 43:
        raise unauthorized("无效的登录凭证")
    return payload


def get_current_user(
    request: Request,
    cred: HTTPAuthorizationCredentials | None = Depends(_bearer),
    db: Session = Depends(get_db),
) -> User:
    if cred is None:
        raise unauthorized()
    payload = decode_token(cred.credentials)
    now = int(time.time())
    user = db.get(User, payload["user_id"])
    if user is None:
        raise unauthorized("登录已失效，请重新登录")
    if user.status != "启用":
        raise forbidden("账号已被禁用，请联系管理员")

    update_result = db.execute(
        update(AuthSession)
        .where(
            AuthSession.sid == payload["sid"],
            AuthSession.user_id == user.id,
            AuthSession.last_activity_at > now - JWT_EXPIRE_SECONDS,
        )
        .values(last_activity_at=case(
            (AuthSession.last_activity_at < now, now), else_=AuthSession.last_activity_at,
        ))
    )
    if update_result.rowcount != 1:
        raise unauthorized("登录已失效，请重新登录")
    db.commit()
    # Permission checks use the current account row rather than the role in the JWT.
    db.refresh(user)
    if user.status != "启用":
        raise forbidden("账号已被禁用，请联系管理员")
    db.commit()

    request.state.session_id = payload["sid"]
    request.state.next_token = create_token(user.id, user.role, payload["sid"], now)
    return user


def require_roles(*roles: str):
    def dependency(
        user: User = Depends(get_current_user),
        db: Session = Depends(get_db),
    ) -> User:
        if user.role not in roles:
            record_operation(db, "permission_denied", ",".join(roles), int(time.time()), actor_id=user.id)
            db.commit()
            raise forbidden()
        return user

    return dependency


require_admin = require_roles(ADMIN)


def is_frozen(user: User, now: int) -> bool:
    return user.frozen_until is not None and user.frozen_until > now
