from typing import List

from app.db.models import Item as ItemModel


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
            raise ValueError(
                f"Broken link: item_id {current.item_id} not found in item list."
            )
        current = next_item
        ordered_items.append(current)

    return ordered_items
