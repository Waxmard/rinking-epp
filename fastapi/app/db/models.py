import datetime
from typing import List as ListType, Optional

from sqlalchemy import ForeignKey, String, Text, func
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
import uuid

class Base(DeclarativeBase):
    """Base class for all database models."""
    pass

class User(Base):
    """User model."""

    __tablename__ = "users"

    user_id: Mapped[uuid.UUID] = mapped_column(primary_key=True, index=True)
    username: Mapped[str] = mapped_column(String(50), unique=True, index=True)
    email: Mapped[str] = mapped_column(String(100), unique=True, index=True)
    password_hash: Mapped[str] = mapped_column(String(255))
    created_at: Mapped[datetime.datetime] = mapped_column(server_default=func.now())
    updated_at: Mapped[datetime.datetime] = mapped_column(
        server_default=func.now(), onupdate=func.now()
    )

    # Relationships
    lists: Mapped[ListType["List"]] = relationship(
        "List", back_populates="user", cascade="all, delete-orphan"
    )


class List(Base):
    """List model."""

    __tablename__ = "lists"

    list_id: Mapped[uuid.UUID] = mapped_column(primary_key=True, index=True)
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.user_id"))
    title: Mapped[str] = mapped_column(String(100))
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime.datetime] = mapped_column(server_default=func.now())
    updated_at: Mapped[datetime.datetime] = mapped_column(
        server_default=func.now(), onupdate=func.now()
    )

    # Relationships
    user: Mapped[User] = relationship("User", back_populates="lists")
    items: Mapped[ListType["Item"]] = relationship(
        "Item", back_populates="list", cascade="all, delete-orphan"
    )


class Item(Base):
    """Item model."""

    __tablename__ = "items"

    item_id: Mapped[uuid.UUID] = mapped_column(primary_key=True, index=True)
    list_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("lists.list_id"))
    name: Mapped[str] = mapped_column(String(100))
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    image_url: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    prev_item_id: Mapped[Optional[uuid.UUID]] = mapped_column(nullable=True)
    next_item_id: Mapped[Optional[uuid.UUID]] = mapped_column(nullable=True)
    rating: Mapped[Optional[float]] = mapped_column(nullable=True)
    tier: Mapped[Optional[str]] = mapped_column(String(1), nullable=True)
    created_at: Mapped[datetime.datetime] = mapped_column(server_default=func.now())
    updated_at: Mapped[datetime.datetime] = mapped_column(
        server_default=func.now(), onupdate=func.now()
    )

    # Relationships
    list: Mapped[List] = relationship("List", back_populates="items")
