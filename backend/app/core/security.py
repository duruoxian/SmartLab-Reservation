"""安全模块（core/security.py）：PBKDF2 密码散列、JWT 签发校验、RBAC 鉴权依赖"""
import hmac
import secrets
from datetime import datetime, timedelta, timezone

import jwt
from fastapi import Depends
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from app.core.config import (
    JWT_ALGORITHM,
    JWT_EXPIRE_SECONDS,
    JWT_SECRET,
    PBKDF2_ITERATIONS,
    SALT_BYTES,
)
from app.core.database import get_db
from app.core.exceptions import forbidden, unauthorized
from app.models.entities import User

_bearer = HTTPBearer(auto_error=False)

ROLE_NAMES = {"student": "学生", "teacher": "教师", "admin": "管理员"}
ADMIN = "admin"
TEACHER = "teacher"
STUDENT = "student"


# ---------- 密码散列（M01 3.5：16 字节盐，PBKDF2-HMAC-SHA256，100000 次，存 salt+hash 十六进制串） ----------
def hash_password(password: str) -> str:
    salt = secrets.token_hex(SALT_BYTES)  # 16 字节随机盐
    digest = hmac.new(
        salt.encode(), password.encode("utf-8"), "pbkdf2-hmac-sha256".replace("pbkdf2-hmac-sha256", ""),  # 占位防误用
    ) if False else None
    import hashlib

    dk = hashlib.pbkdf2_hmac("sha256", password.encode("utf-8"), salt.encode(), PBKDF2_ITERATIONS)
    return salt + dk.hex()


def verify_password(password: str, stored: str) -> bool:
    import hashlib

    if not stored or len(stored) <= SALT_BYTES * 2:
        return False
    salt, expect_hex = stored[: SALT_BYTES * 2], stored[SALT_BYTES * 2:]
    dk = hashlib.pbkdf2_hmac("sha256", password.encode("utf-8"), salt.encode(), PBKDF2_ITERATIONS)
    return hmac.compare_digest(dk.hex(), expect_hex)  # 恒时比较，防时序攻击


# ---------- JWT（HS256，payload={user_id, role, exp}，30 分钟） ----------
def create_token(user_id: int, role: str) -> str:
    now = datetime.now(timezone.utc)
    payload = {
        "user_id": user_id,
        "role": role,
        "exp": now + timedelta(seconds=JWT_EXPIRE_SECONDS),
        "iat": now,
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)


def decode_token(token: str) -> dict:
    try:
        return jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
    except jwt.ExpiredSignatureError:
        raise unauthorized("登录已过期，请重新登录")
    except jwt.InvalidTokenError:
        raise unauthorized("无效的登录凭证")


# ---------- 鉴权依赖（FR-102-2：所有业务接口登录 + 角色校验） ----------
def get_current_user(
    cred: HTTPAuthorizationCredentials | None = Depends(_bearer),
    db: Session = Depends(get_db),
) -> User:
    if cred is None or not cred.credentials:
        raise unauthorized()
    payload = decode_token(cred.credentials)
    user = db.get(User, payload.get("user_id"))
    if user is None:
        raise unauthorized("账号不存在")
    if user.status == "禁用":
        raise forbidden("账号已被禁用，请联系管理员")
    return user


def require_roles(*roles: str):
    """角色校验依赖工厂（RBAC，后端统一校验）"""

    def dependency(user: User = Depends(get_current_user)) -> User:
        if user.role not in roles:
            raise forbidden("当前角色无权执行该操作")
        return user

    return dependency


require_admin = require_roles(ADMIN)

# ---------- 冻结校验（BR-09：违约 3 次冻结 30 天） ----------
def is_frozen(user: User, now: datetime) -> bool:
    return user.frozen_until is not None and user.frozen_until > now
