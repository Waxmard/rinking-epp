from typing import AsyncGenerator, Optional
from uuid import UUID
from datetime import datetime

from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy import select

from app.db.models import Item, List, User, Base
from app.settings import settings
import bcrypt

# Create async engine
engine = create_async_engine(str(settings.DATABASE_URL))
SessionLocal = async_sessionmaker(engine, expire_on_commit=False, class_=AsyncSession)


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
            await conn.run_sync(Base.metadata.drop_all)

        await conn.run_sync(Base.metadata.create_all)
            
    if settings.APP_ENV == "development":
        # Create default development user
        default_user = User(
            user_id=UUID("123e4567-e89b-12d3-a456-426614174000"),
            username="developer",
            email="dev@example.com",
            password_hash=bcrypt.hashpw(b"devpassword", bcrypt.gensalt()).decode('utf-8'),
            created_at=datetime.now(),
            updated_at=datetime.now()
        )
        
        try:
            async with SessionLocal() as session:
                session.add(default_user)
                await session.commit()
        except Exception as e:
            print(f"Error creating default user: {e}")
            raise


async def create_user(db: AsyncSession, username: str, email: str, password_hash: str) -> User:
    """
    Create a new user.

    Args:
        db: Database session
        username: Username for the user
        email: Email address for the user
        password_hash: Hashed password for the user

    Returns:
        Created User object
    """
    user = User(username=username, email=email, password_hash=password_hash)
    db.add(user)
    await db.commit()
    await db.refresh(user)
    return user


async def create_user_list(db: AsyncSession, user: User, title: str, description: Optional[str] = None) -> List:
    """
    Create a new list for a specific user, linking it directly to the user object.

    Args:
        db: Database session
        user: User object to associate the list with
        title: Title of the list
        description: Optional description of the list

    Returns:
        Created List object
    """
    list = List(user=user, title=title, description=description)
    db.add(list)
    await db.commit()
    await db.refresh(list)
    return list


async def add_item_to_user_list(db: AsyncSession, list: List, name: str, description: Optional[str] = None,
                              image_url: Optional[str] = None, position: Optional[int] = None,
                              rating: Optional[float] = None) -> Item:
    """
    Add an item to a specific user's list, linking it directly to the list object.

    Args:
        db: Database session
        list: List object to add the item to
        name: Name of the item
        description: Optional description of the item
        image_url: Optional URL of the item's image
        position: Optional position of the item in the list
        rating: Optional rating for the item

    Returns:
        Created Item object
    """
    item = Item(
        list=list,
        name=name,
        description=description,
        image_url=image_url,
        position=position,
        rating=rating
    )
    db.add(item)
    await db.commit()
    await db.refresh(item)
    return item


async def get_user_by_username(db: AsyncSession, username: str) -> Optional[User]:
    """
    Get a user by username.

    Args:
        db: Database session
        username: Username to search for

    Returns:
        User object if found, None otherwise
    """
    result = await db.execute(select(User).where(User.username == username))
    return result.scalar_one_or_none()


async def get_user_lists_with_items(db: AsyncSession, user_id: int) -> list[tuple[List, list[Item]]]:
    """
    Get all lists belonging to a user along with their items.

    Args:
        db: Database session
        user_id: ID of the user

    Returns:
        List of tuples containing (List object, list of Item objects)
    """
    result = await db.execute(
        select(List, Item)
        .outerjoin(Item, Item.list_id == List.list_id)
        .where(List.user_id == user_id)
    )
    
    # Group items by list
    lists_with_items = {}
    for list, item in result:
        if list.list_id not in lists_with_items:
            lists_with_items[list.list_id] = (list, [])
        if item:
            lists_with_items[list.list_id][1].append(item)
    
    return list(lists_with_items.values())


async def get_list_with_items(db: AsyncSession, list_id: int) -> tuple[List, list[Item]]:
    """
    Get a specific list along with all its items.

    Args:
        db: Database session
        list_id: ID of the list

    Returns:
        Tuple of (List object, list of Item objects)
    """
    result = await db.execute(
        select(List, Item)
        .outerjoin(Item, Item.list_id == List.list_id)
        .where(List.list_id == list_id)
    )
    
    list_obj = None
    items = []
    for list, item in result:
        if list_obj is None:
            list_obj = list
        if item:
            items.append(item)
    
    return list_obj, items
