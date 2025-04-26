from typing import AsyncGenerator

from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase

from app.settings import settings

# Create async engine
engine = create_async_engine(str(settings.DATABASE_URL))
SessionLocal = async_sessionmaker(engine, expire_on_commit=False, class_=AsyncSession)


class Base(DeclarativeBase):
    """Base class for all database models."""

    pass


async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """
    Dependency function that yields db sessions.

    Usage:
        @app.get("/users/")
        async def get_users(db: AsyncSession = Depends(get_db)):
            ...
    """
    async with SessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()


async def create_tables() -> None:
    """Create all database tables."""
    async with engine.begin() as conn:
        # Only use in development, for production use Alembic migrations
        if settings.APP_ENV == "development":
            # Import all models here
            from app.db.models import Item, List, User  # noqa

            await conn.run_sync(Base.metadata.create_all)
