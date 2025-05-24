from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import get_password_hash
from app.db.models import User
from app.schemas.user import UserCreate, UserUpdate
import uuid
from datetime import datetime


async def get_user_by_email(db: AsyncSession, email: str) -> User | None:
    """
    Get a user by email.
    """
    result = await db.execute(select(User).where(User.email == email))
    return result.scalar_one_or_none()


async def get_user_by_id(db: AsyncSession, user_id: int) -> User | None:
    """
    Get a user by ID.
    """
    result = await db.execute(select(User).where(User.user_id == user_id))
    return result.scalar_one_or_none()


async def create_user(db: AsyncSession, obj_in: UserCreate) -> User:
    """
    Create a new user.
    """
    db_obj = User(
        user_id=uuid.uuid4(),
        email=obj_in.email,
        username=obj_in.username,
        password_hash=get_password_hash(obj_in.password),
        created_at=datetime.now(),
        updated_at=datetime.now(),
    )
    db.add(db_obj)
    await db.commit()
    await db.refresh(db_obj)
    return db_obj


async def update_user(db: AsyncSession, db_obj: User, obj_in: UserUpdate) -> User:
    """
    Update a user.
    """
    update_data = obj_in.dict(exclude_unset=True)

    # Handle password update separately
    if "password" in update_data:
        hashed_password = get_password_hash(update_data["password"])
        del update_data["password"]
        update_data["password_hash"] = hashed_password

    # Update attributes
    for field, value in update_data.items():
        setattr(db_obj, field, value)

    db.add(db_obj)
    await db.commit()
    await db.refresh(db_obj)
    return db_obj


async def delete_user(db: AsyncSession, user_id: int) -> None:
    """
    Delete a user.
    """
    user = await get_user_by_id(db, user_id)
    if user:
        await db.delete(user)
        await db.commit()
