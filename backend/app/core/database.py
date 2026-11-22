"""数据库引擎与会话（开发期 SQLite 启用 WAL，概要设计 5.2）"""
from pathlib import Path

from sqlalchemy import create_engine, event, text
from sqlalchemy.engine import make_url
from sqlalchemy.orm import DeclarativeBase, Session, sessionmaker

from app.core.config import DB_MODE, DB_URL

engine = create_engine(
    DB_URL,
    echo=False,
    future=True,
    pool_pre_ping=DB_MODE == "mysql",
    connect_args={"check_same_thread": False, "timeout": 8} if DB_MODE == "sqlite" else {},
)

if DB_MODE == "sqlite":
    @event.listens_for(engine, "connect")
    def _set_sqlite_pragma(dbapi_conn, _):  # noqa: ANN001
        cur = dbapi_conn.cursor()
        try:
            cur.execute("PRAGMA journal_mode=WAL")
            cur.execute("PRAGMA foreign_keys=ON")
        finally:
            cur.close()

SessionLocal = sessionmaker(bind=engine, autoflush=False, expire_on_commit=False, future=True)


class Base(DeclarativeBase):
    pass


def initialize_schema() -> None:
    if DB_MODE == "sqlite":
        database_path = make_url(DB_URL).database
        if database_path and database_path != ":memory:":
            Path(database_path).parent.mkdir(parents=True, exist_ok=True)
    Base.metadata.create_all(engine)


def begin_write(db: Session) -> None:
    """Acquire the SQLite write lock before reading state that will be updated."""
    if DB_MODE == "sqlite":
        db.connection().exec_driver_sql("BEGIN IMMEDIATE")


def get_db():
    """FastAPI 依赖：请求级会话；写库操作在 Service 层事务内完成（详细设计第2章）"""
    db = SessionLocal()
    try:
        yield db
        db.commit()
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


def ping() -> bool:
    try:
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        return True
    except Exception:
        return False
