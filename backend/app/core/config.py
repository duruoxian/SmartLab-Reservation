"""Runtime configuration for the local server and the MySQL deployment."""

import os
import secrets
from pathlib import Path

from sqlalchemy.engine import make_url

BACKEND_DIR = Path(__file__).resolve().parents[2]
DB_URL = os.environ.get(
    "SMARTLAB_DB_URL",
    "sqlite:///" + (BACKEND_DIR / "data" / "smartlab.sqlite3").as_posix(),
)
DB_MODE = make_url(DB_URL).get_backend_name()
if DB_MODE not in {"sqlite", "mysql"}:
    raise ValueError("SMARTLAB_DB_URL must point to SQLite or MySQL.")

JWT_SECRET = os.environ.get("SMARTLAB_JWT_SECRET", "")
if JWT_SECRET and len(JWT_SECRET.encode("utf-8")) < 32:
    raise ValueError("SMARTLAB_JWT_SECRET needs at least 32 bytes.")
if DB_MODE == "mysql" and not JWT_SECRET:
    raise ValueError("Set SMARTLAB_JWT_SECRET before starting a MySQL deployment.")
JWT_SECRET = JWT_SECRET or secrets.token_urlsafe(48)
JWT_ALGORITHM = "HS256"
JWT_EXPIRE_SECONDS = 30 * 60
PBKDF2_ITERATIONS = 100_000
SALT_BYTES = 16
LOGIN_FAILURE_LIMIT = 5
LOGIN_LOCK_SECONDS = 10 * 60
