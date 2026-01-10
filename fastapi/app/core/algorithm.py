from typing import Any, List

from app.schemas.item import Comparison


def find_next_comparison(all_items: List[Any], comparison: Comparison) -> Comparison:
    """
    Return the next comparison item

    This fetches all items in the list and performs binary search to get the next item to compare
    """
    if comparison.is_winner:
        comparison.max_index = comparison.comparison_index
    else:
        comparison.min_index = comparison.comparison_index

    comparison.comparison_index = (comparison.min_index + comparison.max_index) // 2
    comparison.target_item = all_items[comparison.comparison_index]
    comparison.done = (
        True if comparison.max_index - comparison.min_index <= 1 else False
    )
    return comparison
