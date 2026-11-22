from concurrent.futures import ThreadPoolExecutor
import time
from uuid import uuid4

from sqlalchemy import select


def registration(role="student"):
    return {
        "user_no": "u" + uuid4().hex[:9], "name": "联调用户", "role": role,
        "college": "计算机学院", "major": "软件工程", "phone": "13800138001",
        "password": "TestOnly123",
    }


def create_account(client, role="student"):
    form = registration(role)
    if role == "admin":
        from app.core.database import SessionLocal
        from app.models.schemas import NewAccount
        from app.services.user_service import create_account as create
        with SessionLocal() as session:
            body = create(session, NewAccount(**{k: v for k, v in form.items() if k != "role"}), role)
    else:
        response = client.post("/api/auth/register", json=form)
        assert response.status_code == 200
        body = response.json()["data"]
    return form, body


def sign_in(client, form):
    return client.post("/api/auth/login", json={key: form[key] for key in ("user_no", "password")})


def bearer(token):
    return {"Authorization": f"Bearer {token}"}


def sign_in_token(client, form):
    response = sign_in(client, form)
    assert response.status_code == 200, response.text
    return response.json()["data"]["token"]


def test_registration_and_private_profile(client):
    form, data = create_account(client, "teacher")
    assert len(data["recovery_code"]) == 24
    assert data["user"]["role"] == "teacher"
    assert "password_hash" not in data["user"] and "recovery_hash" not in data["user"]
    assert client.post("/api/auth/register", json=form).status_code == 409
    assert client.post("/api/auth/register", json=registration("admin")).status_code == 400
    options = client.get("/api/auth/roles").json()["data"]
    assert [role["code"] for role in options] == ["student", "teacher"]
    assert client.get("/api/users/me").status_code == 401
    token = sign_in_token(client, {**form, "user_no": form["user_no"].upper()})
    response = client.put("/api/users/me", headers=bearer(token), json={
        "phone": "13900139000", "college": "工程学院", "major": "计算机科学",
    })
    assert response.status_code == 200
    assert response.json()["data"]["phone"] == "13900139000"
    assert response.headers["X-SmartLab-Token"]
    assert client.put("/api/users/me", headers=bearer(token), json={**form, "role": "admin"}).status_code == 400


def test_parallel_login_failures_are_saved_and_lock_account(client):
    from app.core.database import SessionLocal
    from app.models.entities import User

    form, created = create_account(client)
    attempt = {"user_no": form["user_no"], "password": "WrongPass123"}
    with ThreadPoolExecutor(max_workers=5) as pool:
        replies = list(pool.map(lambda _: client.post("/api/auth/login", json=attempt), range(5)))
    assert sorted(reply.status_code for reply in replies) == [401] * 4 + [423]
    assert sign_in(client, form).status_code == 423
    with SessionLocal.begin() as db:
        user = db.get(User, created["user"]["id"])
        assert user.fail_count == 5
        assert user.lock_until > time.time()
        user.lock_until = int(time.time()) - 1
    assert sign_in(client, form).status_code == 200
    with SessionLocal() as db:
        user = db.get(User, created["user"]["id"])
        assert (user.fail_count, user.lock_until) == (0, None)


def test_idle_expiry_rolling_token_and_logout(client):
    from app.core.database import SessionLocal
    from app.core.security import create_token, decode_token
    from app.models.entities import AuthSession

    form, _ = create_account(client)
    token = sign_in_token(client, form)
    claims = decode_token(token)
    earlier_token = create_token(claims["user_id"], claims["role"], claims["sid"], int(time.time()) - 1700)
    response = client.get("/api/users/me", headers=bearer(earlier_token))
    assert response.status_code == 200
    renewed = response.headers["X-SmartLab-Token"]
    assert decode_token(renewed)["exp"] > decode_token(earlier_token)["exp"]
    with SessionLocal.begin() as db:
        db.get(AuthSession, claims["sid"]).last_activity_at = int(time.time()) - 1801
    assert client.get("/api/users/me", headers=bearer(renewed)).status_code == 401
    fresh_token = sign_in_token(client, form)
    logout = client.post("/api/auth/logout", headers=bearer(fresh_token))
    assert logout.status_code == 200
    assert "X-SmartLab-Token" not in logout.headers
    assert client.get("/api/users/me", headers=bearer(fresh_token)).status_code == 401


def test_recovery_is_single_use_and_revokes_sessions(client):
    form, data = create_account(client)
    token = sign_in_token(client, form)
    reset = {
        "user_no": form["user_no"], "phone": form["phone"],
        "recovery_code": data["recovery_code"], "new_password": "ResetOnly456",
    }
    assert client.post("/api/auth/reset-password", json={**reset, "phone": "13900139001"}).status_code == 409
    assert client.post("/api/auth/reset-password", json=reset).status_code == 200
    assert client.post("/api/auth/reset-password", json=reset).status_code == 409
    assert client.get("/api/users/me", headers=bearer(token)).status_code == 401
    assert sign_in(client, form).status_code == 401
    new_token = sign_in_token(client, {**form, "password": reset["new_password"]})
    replacement = client.post("/api/users/me/recovery-code", headers=bearer(new_token),
                              json={"current_password": reset["new_password"]})
    assert replacement.status_code == 200
    assert replacement.json()["data"]["recovery_code"] != data["recovery_code"]
    changed = client.put("/api/users/me/password", headers=bearer(new_token), json={
        "current_password": reset["new_password"], "new_password": "NextPass789",
    })
    assert changed.status_code == 200
    assert client.get("/api/users/me", headers=bearer(new_token)).status_code == 401
    assert sign_in(client, {**form, "password": "NextPass789"}).status_code == 200


def test_admin_role_changes_apply_to_existing_token_and_are_audited(client):
    from app.core.database import SessionLocal
    from app.models.entities import OperationLog, User

    form, account = create_account(client)
    uid = account["user"]["id"]
    admin, admin_account = create_account(client, "admin")
    actor_id = admin_account["user"]["id"]
    member_headers = bearer(sign_in_token(client, form))
    admin_headers = bearer(sign_in_token(client, admin))
    assert client.get("/api/admin/users", headers=member_headers).status_code == 403
    assert client.put(f"/api/admin/users/{uid}/role", headers=member_headers, json={"role": "admin"}).status_code == 403
    assert client.put(f"/api/admin/users/{actor_id}/role", headers=admin_headers, json={"role": "student"}).status_code == 409
    assert client.put(f"/api/admin/users/{uid}/role", headers=admin_headers, json={"role": "admin"}).status_code == 200
    page = client.get("/api/admin/users", headers=member_headers, params={"keyword": form["user_no"]})
    assert [item["id"] for item in page.json()["data"]["items"]] == [uid]
    assert client.put(f"/api/admin/users/{uid}/role", headers=admin_headers, json={"role": "teacher"}).status_code == 200
    assert client.get("/api/admin/users", headers=member_headers).status_code == 403
    with SessionLocal.begin() as db:
        logs = db.scalars(select(OperationLog).where(OperationLog.target_user_id == uid, OperationLog.action == "role_change")).all()
        assert [(entry.actor_id, entry.result) for entry in logs] == [(actor_id, "student->admin"), (actor_id, "admin->teacher")]
        db.get(User, uid).status = "禁用"
    assert sign_in(client, form).status_code == 403
    assert client.get("/api/users/me", headers=member_headers).status_code == 403
