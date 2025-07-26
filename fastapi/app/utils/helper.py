from typing import List
from app.db.models import Item as ItemModel
from app.schemas.item import Item

def sort_items_linked_list_style(all_items: List[ItemModel]) -> List[ItemModel]:
    """
    Sorts items from lowest to highest using next_item_id pointers.
    The highest ranked item has null next_item_id.
    The lowest ranked item has null prev_item_id.
    """
    if not all_items:
        return []

    # Map from item_id to item
    id_to_next_item = {item.item_id: item for item in all_items}
    
    head = next((item for item in all_items if item.prev_item_id is None), None)
    
    if not head:
        raise ValueError("Invalid linked list structure: no head items found.")

    current = head
    ordered_items = [current]

    while current.next_item_id:
        next_item = id_to_next_item.get(current.next_item_id)
        if not next_item:
            raise ValueError(f"Broken link: item_id {current.item_id} not found in item list.")
        current = next_item
        ordered_items.append(current)

    return ordered_items

def convert_pydantic_to_sqlalchemy(pyd_item: Item) -> ItemModel:
    return ItemModel(
        item_id=pyd_item.item_id,
        list_id=pyd_item.list_id,
        name=pyd_item.name,
        description=pyd_item.description,
        image_url=str(pyd_item.image_url) if pyd_item.image_url else None,
        prev_item_id=pyd_item.prev_item_id,
        next_item_id=pyd_item.next_item_id,
        rating=pyd_item.rating,
        tier=pyd_item.tier.value if pyd_item.tier else None,  # assuming TierRank is an Enum
        created_at=pyd_item.created_at,
        updated_at=pyd_item.updated_at,
    )