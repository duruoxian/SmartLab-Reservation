"""Tables owned by M01."""

from sqlalchemy import ForeignKey, Index, Integer, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column

from app.core.database import Base


class User(Base):
    __tablename__ = "t_user"

    id: Mapped[int] = mapped_column(primary_key=True)
    user_no: Mapped[str] = mapped_column(String(12), unique=True)
    name: Mapped[str] = mapped_column(String(20))
    role: Mapped[str] = mapped_column(String(16), index=True)
    college: Mapped[str] = mapped_column(String(60))
    major: Mapped[str] = mapped_column(String(60))
    phone: Mapped[str] = mapped_column(String(11))
    password_hash: Mapped[str] = mapped_column(String(96))
    recovery_hash: Mapped[str | None] = mapped_column(String(64))
    status: Mapped[str] = mapped_column(String(8), default="启用")
    fail_count: Mapped[int] = mapped_column(default=0)
    lock_until: Mapped[int | None] = mapped_column(Integer)
    violation_count: Mapped[int] = mapped_column(default=0)
    frozen_until: Mapped[int | None] = mapped_column(Integer)
    created_at: Mapped[int]


class DictionaryItem(Base):
    __tablename__ = "t_dict"
    __table_args__ = (UniqueConstraint("type", "code", name="uq_dict_type_code"),)

    id: Mapped[int] = mapped_column(primary_key=True)
    type: Mapped[str] = mapped_column(String(20))
    code: Mapped[str] = mapped_column(String(24))
    name: Mapped[str] = mapped_column(String(30))
    sort_order: Mapped[int]


class OperationLog(Base):
    __tablename__ = "t_operation_log"
    __table_args__ = (Index("ix_operation_log_action_time", "action", "created_at"),)

    id: Mapped[int] = mapped_column(primary_key=True)
    actor_id: Mapped[int | None]
    target_user_id: Mapped[int | None]
    action: Mapped[str] = mapped_column(String(36))
    result: Mapped[str] = mapped_column(String(80))
    created_at: Mapped[int]


class AuthSession(Base):
    __tablename__ = "t_auth_session"

    sid: Mapped[str] = mapped_column(String(43), primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("t_user.id", ondelete="CASCADE"), index=True)
    last_activity_at: Mapped[int] = mapped_column(index=True)
