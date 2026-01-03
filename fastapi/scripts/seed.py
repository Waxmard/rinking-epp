#!/usr/bin/env python3
"""
Database seed script for local development.

Creates dev users with known credentials for testing.
Run with: make seed
"""

import asyncio
import sys
from pathlib import Path

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

from datetime import datetime
import uuid

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.database import SessionLocal, engine
from app.db.models import Base, User
from app.core.security import get_password_hash


# Dev user to seed
DEV_USERS = [
    {
        "email": "dev@tiernerd.com",
        "username": "dev",
        "password": "devpassword",
    },
]


async def clear_database(session: AsyncSession) -> None:
    """Clear all data from the database."""
    # Delete in order to respect foreign keys
    await session.execute(text("DELETE FROM items"))
    await session.execute(text("DELETE FROM lists"))
    await session.execute(text("DELETE FROM users"))
    await session.commit()
    print("Cleared all data from database")


async def seed_users(session: AsyncSession) -> None:
    """Create dev users."""
    for user_data in DEV_USERS:
        user = User(
            user_id=uuid.uuid4(),
            email=user_data["email"],
            username=user_data["username"],
            password_hash=get_password_hash(user_data["password"]),
            created_at=datetime.now(),
            updated_at=datetime.now(),
        )
        session.add(user)
        print(f"Created user: {user_data['email']} / {user_data['password']}")

    await session.commit()


async def main(clear: bool = False) -> None:
    """Main seed function."""
    print("Starting database seed...")

    # Create tables if they don't exist
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    async with SessionLocal() as session:
        if clear:
            await clear_database(session)

        await seed_users(session)

    print("\nDev credentials:")
    print("-" * 40)
    for user in DEV_USERS:
        print(f"  {user['email']} / {user['password']}")
    print("-" * 40)
    print("Seed complete!")


if __name__ == "__main__":
    clear = "--clear" in sys.argv or "-c" in sys.argv
    asyncio.run(main(clear=clear))
