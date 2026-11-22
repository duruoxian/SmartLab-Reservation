"""Database access for the user and permission module."""

from sqlalchemy import delete, or_, select
from sqlalchemy.orm import Session

from app.models.entities import AuthSession, DictionaryItem, OperationLog, User


def find_by_number(db: Session, user_no: str, *, lock: bool = False) -> User | None:
    query = select(User).where(User.user_no == user_no)
    return db.scalar(query.with_for_update() if lock else query)


def role_items(db: Session) -> list[DictionaryItem]:
    return list(db.scalars(
        select(DictionaryItem)
        .where(DictionaryItem.type == "role")
        .order_by(DictionaryItem.sort_order)
    ))


def list_users(db: Session, keyword: str, page: int, page_size: int) -> list[User]:
    query = select(User)
    if keyword:
        query = query.where(or_(User.user_no.contains(keyword, autoescape=True), User.name.contains(keyword, autoescape=True)))
    return list(db.scalars(query.order_by(User.id).offset((page - 1) * page_size).limit(page_size + 1)))


def remove_sessions(db: Session, user_id: int) -> None:
    db.execute(delete(AuthSession).where(AuthSession.user_id == user_id))


def remove_idle_sessions(db: Session, user_id: int, cutoff: int) -> None:
    db.execute(delete(AuthSession).where(AuthSession.user_id == user_id, AuthSession.last_activity_at <= cutoff))


def record_operation(
    db: Session, action: str, result: str, now: int, *,
    actor_id: int | None = None, target_id: int | None = None,
) -> None:
    db.add(OperationLog(
        actor_id=actor_id, target_user_id=target_id, action=action, result=result, created_at=now,
    ))
