from typing import Any

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.auth import get_current_user
from app.db.database import get_db
from app.db.models import Item as ItemModel
from app.db.models import List as ListModel
from app.schemas.list import List, ListCreate, ListSimple, ListUpdate
from app.schemas.user import User

router = APIRouter()


@router.get("/", response_model=List[ListSimple])
async def read_lists(
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    """
    Retrieve lists created by the current user.
    """
    # Get lists with item count
    query = (
        select(ListModel, func.count(ItemModel.item_id).label("item_count"))
        .outerjoin(ItemModel)
        .where(ListModel.user_id == current_user.user_id)
        .group_by(ListModel.list_id)
        .offset(skip)
        .limit(limit)
    )

    result = await db.execute(query)
    lists_with_counts = result.all()

    # Prepare response
    response = []
    for list_obj, item_count in lists_with_counts:
        list_dict = {
            "list_id": list_obj.list_id,
            "user_id": list_obj.user_id,
            "title": list_obj.title,
            "description": list_obj.description,
            "created_at": list_obj.created_at,
            "updated_at": list_obj.updated_at,
            "item_count": item_count,
        }
        response.append(list_dict)

    return response


@router.post("/", response_model=List)
async def create_list(
    list_in: ListCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    """
    Create new list.
    """
    list_obj = ListModel(
        title=list_in.title,
        description=list_in.description,
        user_id=current_user.user_id,
    )
    db.add(list_obj)
    await db.commit()
    await db.refresh(list_obj)

    # Return with empty items list
    return {
        "list_id": list_obj.list_id,
        "user_id": list_obj.user_id,
        "title": list_obj.title,
        "description": list_obj.description,
        "created_at": list_obj.created_at,
        "updated_at": list_obj.updated_at,
        "items": [],
    }


@router.get("/{list_id}", response_model=List)
async def read_list(
    list_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    """
    Get a specific list by ID with all its items.
    """
    # Get the list
    query = select(ListModel).where(
        ListModel.list_id == list_id, ListModel.user_id == current_user.user_id
    )
    result = await db.execute(query)
    list_obj = result.scalar_one_or_none()

    if not list_obj:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="List not found"
        )

    # Get items in this list
    query = (
        select(ItemModel)
        .where(ItemModel.list_id == list_id)
        .order_by(ItemModel.position)
    )

    result = await db.execute(query)
    items = result.scalars().all()

    # Format items
    items_data = [
        {
            "item_id": item.item_id,
            "list_id": item.list_id,
            "name": item.name,
            "description": item.description,
            "image_url": item.image_url,
            "position": item.position,
            "rating": item.rating,
            "created_at": item.created_at,
            "updated_at": item.updated_at,
        }
        for item in items
    ]

    # Prepare response
    return {
        "list_id": list_obj.list_id,
        "user_id": list_obj.user_id,
        "title": list_obj.title,
        "description": list_obj.description,
        "created_at": list_obj.created_at,
        "updated_at": list_obj.updated_at,
        "items": items_data,
    }


@router.put("/{list_id}", response_model=List)
async def update_list(
    list_id: int,
    list_in: ListUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    """
    Update a list.
    """
    # Get the list
    query = select(ListModel).where(
        ListModel.list_id == list_id, ListModel.user_id == current_user.user_id
    )
    result = await db.execute(query)
    list_obj = result.scalar_one_or_none()

    if not list_obj:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="List not found"
        )

    # Update fields
    update_data = list_in.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(list_obj, field, value)

    db.add(list_obj)
    await db.commit()
    await db.refresh(list_obj)

    # Get items to include in response
    query = (
        select(ItemModel)
        .where(ItemModel.list_id == list_id)
        .order_by(ItemModel.position)
    )

    result = await db.execute(query)
    items = result.scalars().all()

    # Format items
    items_data = [
        {
            "item_id": item.item_id,
            "list_id": item.list_id,
            "name": item.name,
            "description": item.description,
            "image_url": item.image_url,
            "position": item.position,
            "rating": item.rating,
            "created_at": item.created_at,
            "updated_at": item.updated_at,
        }
        for item in items
    ]

    # Prepare response
    return {
        "list_id": list_obj.list_id,
        "user_id": list_obj.user_id,
        "title": list_obj.title,
        "description": list_obj.description,
        "created_at": list_obj.created_at,
        "updated_at": list_obj.updated_at,
        "items": items_data,
    }


@router.delete("/{list_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_list(
    list_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> None:
    """
    Delete a list.
    """
    # Get the list
    query = select(ListModel).where(
        ListModel.list_id == list_id, ListModel.user_id == current_user.user_id
    )
    result = await db.execute(query)
    list_obj = result.scalar_one_or_none()

    if not list_obj:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="List not found"
        )

    # Delete the list (items will be cascade deleted due to relationship)
    await db.delete(list_obj)
    await db.commit()
