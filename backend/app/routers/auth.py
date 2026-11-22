"""Public account operations and authenticated M01 endpoints."""

from typing import Annotated

from fastapi import APIRouter, Depends, Query, Request
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.response import response
from app.core.security import get_current_user, require_admin
from app.models.entities import User
from app.models.schemas import ChangePassword, CurrentPassword, Login, ProfileUpdate, Registration, ResetPassword, RoleUpdate
from app.services import user_service as service

router = APIRouter(prefix="/api", tags=["M01 用户与权限"])
Db = Annotated[Session, Depends(get_db)]
CurrentUser = Annotated[User, Depends(get_current_user)]
AdminUser = Annotated[User, Depends(require_admin)]


@router.get("/auth/roles")
def roles(db: Db):
    return response(service.registration_roles(db))


@router.post("/auth/register")
def register(form: Registration, db: Db):
    return response(service.create_account(db, form, form.role), "注册成功")


@router.post("/auth/login")
def login(form: Login, db: Db):
    return response(service.login(db, form.user_no, form.password), "登录成功")


@router.post("/auth/reset-password")
def reset_password(form: ResetPassword, db: Db):
    service.reset_password(db, form.user_no, form.phone, form.recovery_code, form.new_password)
    return response(message="密码已重置，请重新登录")


@router.post("/auth/logout")
def logout(request: Request, user: CurrentUser, db: Db):
    service.logout(db, user.id, request.state.session_id)
    request.state.next_token = None
    return response(message="已退出登录")


@router.get("/users/me")
def get_me(user: CurrentUser):
    return response(service.public_user(user))


@router.put("/users/me")
def update_me(form: ProfileUpdate, user: CurrentUser, db: Db):
    return response(service.update_profile(db, user.id, form), "个人资料已保存")


@router.put("/users/me/password")
def change_password(request: Request, form: ChangePassword, user: CurrentUser, db: Db):
    service.change_password(db, user.id, form.current_password, form.new_password)
    request.state.next_token = None
    return response(message="密码已修改，请重新登录")


@router.post("/users/me/recovery-code")
def renew_code(form: CurrentPassword, user: CurrentUser, db: Db):
    code = service.renew_recovery_code(db, user.id, form.current_password)
    return response({"recovery_code": code}, "恢复码已更新")


@router.get("/admin/users")
def list_users(
    _admin: AdminUser, db: Db, keyword: Annotated[str, Query(max_length=60)] = "",
    page: Annotated[int, Query(ge=1, le=100000)] = 1,
    page_size: Annotated[int, Query(ge=1, le=50)] = 20,
):
    return response(service.admin_list(db, keyword, page, page_size))


@router.put("/admin/users/{user_id}/role")
def update_role(user_id: int, form: RoleUpdate, admin: AdminUser, db: Db):
    return response(service.change_role(db, admin.id, user_id, form.role), "角色已更新")
