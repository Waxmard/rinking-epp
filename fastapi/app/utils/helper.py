from typing import List

from app.db.models import Item as ItemModel


def sort_items_by_position(items: List[ItemModel]) -> List[ItemModel]:
    """
    Sort items by their position field.
    Items with position are sorted lexicographically.
    Items without position (unranked) are placed at the end.

    Args:
        items: List of items to sort

    Returns:
        List of items sorted by position, with unranked items at the end
    """
    if not items:
        return []

    ranked = [item for item in items if item.position is not None]
    unranked = [item for item in items if item.position is None]

    # Sort ranked items lexicographically by position
    sorted_ranked = sorted(ranked, key=lambda x: x.position)  # type: ignore[arg-type, return-value]

    return sorted_ranked + unranked
