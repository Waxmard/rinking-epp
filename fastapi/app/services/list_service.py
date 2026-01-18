"""List-related business logic."""

from typing import Any, Dict, List, Optional, Tuple

from app.db.models import Item as ItemModel
from app.utils.helper import sort_items_linked_list_style


def group_items_by_tier_set(items: List[ItemModel]) -> Dict[Optional[str], List]:
    """
    Group items by their tier_set value.

    Args:
        items: List of items to group

    Returns:
        Dictionary mapping tier_set to list of items
    """
    groups: Dict[Optional[str], List] = {}
    for item in items:
        tier_set = item.tier_set
        if tier_set not in groups:
            groups[tier_set] = []
        groups[tier_set].append(item)
    return groups


def get_items_sorted_by_tier_set(items: List[ItemModel]) -> List[ItemModel]:
    """
    Sort items by their tier_set's linked list order.
    Each tier_set has its own linked list, so we sort each group separately
    and then combine them.

    Args:
        items: List of items to sort

    Returns:
        List of items sorted by tier_set linked list order
    """
    if not items:
        return []

    # Group items by tier_set since each tier_set has its own linked list
    tier_set_groups = group_items_by_tier_set(items)

    # Sort each tier_set's linked list separately, then combine
    all_sorted: List = []
    for tier_set, group_items in tier_set_groups.items():
        try:
            sorted_group = sort_items_linked_list_style(group_items)
            all_sorted.extend(sorted_group)
        except ValueError:
            # Linked list structure invalid for this group, add unsorted
            all_sorted.extend(group_items)

    return all_sorted


def build_list_response(list_obj: Any, items: Optional[List] = None) -> Dict:
    """
    Build a standard list response dictionary.

    Args:
        list_obj: The list model object
        items: Optional list of items to include

    Returns:
        Dictionary with list data
    """
    response = {
        "list_id": list_obj.list_id,  # type: ignore
        "user_id": list_obj.user_id,  # type: ignore
        "title": list_obj.title,  # type: ignore
        "description": list_obj.description,  # type: ignore
        "created_at": list_obj.created_at,  # type: ignore
        "updated_at": list_obj.updated_at,  # type: ignore
    }
    if items is not None:
        response["items"] = items
    return response


def build_list_simple_response(row: Tuple) -> Dict:
    """
    Build a ListSimple response from a database row with stats.

    Args:
        row: Tuple of (ListModel, item_count, tier_s, tier_a, tier_b, tier_c, tier_d, tier_f)

    Returns:
        Dictionary with list data and statistics
    """
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
    return {
        "list_id": list_obj.list_id,
        "user_id": list_obj.user_id,
        "title": list_obj.title,
        "description": list_obj.description,
        "created_at": list_obj.created_at,
        "updated_at": list_obj.updated_at,
        "item_count": item_count,
        "tier_distribution": tier_distribution,
    }
