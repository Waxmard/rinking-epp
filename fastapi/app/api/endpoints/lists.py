import uuid
from datetime import datetime, timezone
from typing import Any
from typing import List as TypeList

from sqlalchemy import case, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.auth import get_current_user
from app.core.constants import LIST_ALREADY_EXISTS_ERROR, LIST_NOT_FOUND_ERROR
from app.db.database import get_db
from app.db.models import Item as ItemModel
from app.db.models import List as ListModel
from app.schemas.item import Item
from app.schemas.list import List, ListSimple, ListUpdate
from app.schemas.user import User
from app.utils.helper import sort_items_linked_list_style
from fastapi import APIRouter, Depends, HTTPException, status

router = APIRouter()


@router.get("/", response_model=TypeList[ListSimple])
async def read_lists(
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    """
    Retrieve lists created by the current user.
    """
    # Get lists with item count and tier distribution
    query = (
        select(
            ListModel,
            func.count(ItemModel.item_id).label("item_count"),
            func.sum(case((ItemModel.tier == "S", 1), else_=0)).label("tier_s"),
            func.sum(case((ItemModel.tier == "A", 1), else_=0)).label("tier_a"),
            func.sum(case((ItemModel.tier == "B", 1), else_=0)).label("tier_b"),
            func.sum(case((ItemModel.tier == "C", 1), else_=0)).label("tier_c"),
            func.sum(case((ItemModel.tier == "D", 1), else_=0)).label("tier_d"),
            func.sum(case((ItemModel.tier == "F", 1), else_=0)).label("tier_f"),
        )
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
    for row in lists_with_counts:
        list_obj = row[0]
        item_count = row[1] or 0
        tier_distribution = {
            "S": row[2] or 0,
            "A": row[3] or 0,
            "B": row[4] or 0,
            "C": row[5] or 0,
            "D": row[6] or 0,
            "F": row[7] or 0,
        }
        list_dict = {
            "list_id": list_obj.list_id,
            "user_id": list_obj.user_id,
            "title": list_obj.title,
            "description": list_obj.description,
            "created_at": list_obj.created_at,
            "updated_at": list_obj.updated_at,
            "item_count": item_count,
            "tier_distribution": tier_distribution,
        }
        response.append(list_dict)

    return response


@router.post("/", response_model=List)
async def create_list(
    name: str,
    description: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    """
    Create new list.
    """
    # Check if list exists and belongs to current user
    query = select(ListModel).where(
        ListModel.title == name, ListModel.user_id == current_user.user_id
    )
    result = await db.execute(query)
    list_obj = result.scalar_one_or_none()

    if list_obj:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=LIST_ALREADY_EXISTS_ERROR,
        )

    list_obj = ListModel(
        list_id=uuid.uuid4(),
        title=name,
        user_id=current_user.user_id,
        description=description,
        created_at=datetime.now(timezone.utc),
        updated_at=datetime.now(timezone.utc),
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
    }


@router.get("/{list_id}", response_model=List)
async def read_list(
    list_id: uuid.UUID,
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
            status_code=status.HTTP_404_NOT_FOUND, detail=LIST_NOT_FOUND_ERROR
        )

    # Prepare response
    return {
        "list_id": list_obj.list_id,
        "user_id": list_obj.user_id,
        "title": list_obj.title,
        "description": list_obj.description,
        "created_at": list_obj.created_at,
        "updated_at": list_obj.updated_at,
    }


@router.get("/{list_id}/items", response_model=TypeList[Item])
async def read_list_items(
    list_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> Any:
    """
    Get all items for a list, ordered by tier then by linked list position.
    """
    # Verify list exists and belongs to current user
    query = select(ListModel).where(
        ListModel.list_id == list_id, ListModel.user_id == current_user.user_id
    )
    result = await db.execute(query)
    list_obj = result.scalar_one_or_none()

    if not list_obj:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail=LIST_NOT_FOUND_ERROR
        )

    # Fetch all items for this list
    items_query = select(ItemModel).where(ItemModel.list_id == list_id)
    items_result = await db.execute(items_query)
    items = list(items_result.scalars().all())

    if not items:
        return []

    # Group items by tier_set since each tier_set has its own linked list
    tier_set_groups: dict[str | None, list] = {}
    for item in items:
        tier_set = item.tier_set
        if tier_set not in tier_set_groups:
            tier_set_groups[tier_set] = []
        tier_set_groups[tier_set].append(item)

    # Sort each tier_set's linked list separately, then combine
    all_sorted: list = []
    for tier_set, group_items in tier_set_groups.items():
        try:
            sorted_group = sort_items_linked_list_style(group_items)
            all_sorted.extend(sorted_group)
        except ValueError:
            # Linked list structure invalid for this group, add unsorted
            all_sorted.extend(group_items)

    return all_sorted


@router.put("/{list_id}", response_model=List)
async def update_list(
    list_id: uuid.UUID,
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
            status_code=status.HTTP_404_NOT_FOUND, detail=LIST_NOT_FOUND_ERROR
        )

    # Update fields
    update_data = list_in.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(list_obj, field, value)

    db.add(list_obj)
    await db.commit()
    await db.refresh(list_obj)

    # Get items to include in response
    items_query = select(ItemModel).where(ItemModel.list_id == list_id)

    items_result = await db.execute(items_query)
    items = items_result.scalars().all()

    # Format items
    items_data = [
        {
            "item_id": item.item_id,
            "list_id": item.list_id,
            "name": item.name,
            "description": item.description,
            "image_url": item.image_url,
            "position": getattr(item, "position", None),
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
    list_id: uuid.UUID,
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
            status_code=status.HTTP_404_NOT_FOUND, detail=LIST_NOT_FOUND_ERROR
        )

    # Delete the list (items will be cascade deleted due to relationship)
    await db.delete(list_obj)
    await db.commit()
