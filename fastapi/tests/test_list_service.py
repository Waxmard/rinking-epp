"""Tests for list_service module - pure function unit tests."""

import uuid
from datetime import datetime


from app.db.models import Item as ItemModel
from app.services.list_service import (
    build_list_response,
    build_list_simple_response,
    get_items_sorted_by_tier_set,
    group_items_by_tier_set,
)


def create_mock_item(
    name: str,
    tier_set: str | None = "good",
    prev_item_id: uuid.UUID | None = None,
    next_item_id: uuid.UUID | None = None,
) -> ItemModel:
    """Create a mock item for testing."""
    return ItemModel(
        item_id=uuid.uuid4(),
        list_id=uuid.uuid4(),
        name=name,
        description=f"Description for {name}",
        image_url=f"https://example.com/{name}.jpg",
        prev_item_id=prev_item_id,
        next_item_id=next_item_id,
        rating=None,
        tier="A",
        tier_set=tier_set,
        created_at=datetime.now(),
        updated_at=datetime.now(),
    )


class TestGroupItemsByTierSet:
    """Tests for group_items_by_tier_set function."""

    def test_group_items_empty_list(self):
        """Test grouping with empty list."""
        result = group_items_by_tier_set([])
        assert result == {}

    def test_group_items_single_tier_set(self):
        """Test grouping items all in same tier_set."""
        items = [
            create_mock_item("Item 1", tier_set="good"),
            create_mock_item("Item 2", tier_set="good"),
            create_mock_item("Item 3", tier_set="good"),
        ]
        result = group_items_by_tier_set(items)
        assert len(result) == 1
        assert "good" in result
        assert len(result["good"]) == 3

    def test_group_items_multiple_tier_sets(self):
        """Test grouping items across different tier_sets."""
        items = [
            create_mock_item("Good 1", tier_set="good"),
            create_mock_item("Mid 1", tier_set="mid"),
            create_mock_item("Good 2", tier_set="good"),
            create_mock_item("Bad 1", tier_set="bad"),
            create_mock_item("Mid 2", tier_set="mid"),
        ]
        result = group_items_by_tier_set(items)
        assert len(result) == 3
        assert len(result["good"]) == 2
        assert len(result["mid"]) == 2
        assert len(result["bad"]) == 1

    def test_group_items_with_none_tier_set(self):
        """Test grouping items with None tier_set values."""
        items = [
            create_mock_item("Item 1", tier_set=None),
            create_mock_item("Item 2", tier_set="good"),
            create_mock_item("Item 3", tier_set=None),
        ]
        result = group_items_by_tier_set(items)
        assert len(result) == 2
        assert None in result
        assert len(result[None]) == 2
        assert len(result["good"]) == 1

    def test_group_items_preserves_items(self):
        """Test that grouping preserves all item references."""
        item1 = create_mock_item("Item 1", tier_set="good")
        item2 = create_mock_item("Item 2", tier_set="mid")
        items = [item1, item2]
        result = group_items_by_tier_set(items)
        assert result["good"][0] is item1
        assert result["mid"][0] is item2


class TestGetItemsSortedByTierSet:
    """Tests for get_items_sorted_by_tier_set function."""

    def test_sort_empty_list(self):
        """Test sorting empty list returns empty list."""
        result = get_items_sorted_by_tier_set([])
        assert result == []

    def test_sort_single_item(self):
        """Test sorting single item returns list with that item."""
        item = create_mock_item("Only Item", tier_set="good")
        result = get_items_sorted_by_tier_set([item])
        assert len(result) == 1
        assert result[0] is item

    def test_sort_linked_list_single_tier_set(self):
        """Test sorting a valid linked list within a single tier_set."""
        item1 = create_mock_item("Item 1", tier_set="good")
        item2 = create_mock_item("Item 2", tier_set="good")
        item3 = create_mock_item("Item 3", tier_set="good")

        # Set up linked list: item1 -> item2 -> item3
        item1.next_item_id = item2.item_id
        item2.prev_item_id = item1.item_id
        item2.next_item_id = item3.item_id
        item3.prev_item_id = item2.item_id

        # Pass in random order
        items = [item3, item1, item2]
        result = get_items_sorted_by_tier_set(items)

        assert len(result) == 3
        assert result[0] is item1
        assert result[1] is item2
        assert result[2] is item3

    def test_sort_multiple_tier_sets(self):
        """Test sorting items across multiple tier_sets."""
        good1 = create_mock_item("Good 1", tier_set="good")
        good2 = create_mock_item("Good 2", tier_set="good")
        mid1 = create_mock_item("Mid 1", tier_set="mid")

        # Set up linked lists
        good1.next_item_id = good2.item_id
        good2.prev_item_id = good1.item_id

        items = [good2, mid1, good1]
        result = get_items_sorted_by_tier_set(items)

        # Should have all 3 items
        assert len(result) == 3

    def test_sort_invalid_linked_list_structure(self):
        """Test that invalid linked list structure falls back to unsorted."""
        item1 = create_mock_item("Item 1", tier_set="good")
        item2 = create_mock_item("Item 2", tier_set="good")

        # Invalid: both have prev_item_id set (no head)
        item1.prev_item_id = uuid.uuid4()
        item2.prev_item_id = uuid.uuid4()

        items = [item1, item2]
        result = get_items_sorted_by_tier_set(items)

        # Should return items (unsorted due to invalid structure)
        assert len(result) == 2

    def test_sort_broken_link_falls_back(self):
        """Test that broken link falls back to unsorted items."""
        item1 = create_mock_item("Item 1", tier_set="good")
        item2 = create_mock_item("Item 2", tier_set="good")

        # Broken: item1 points to non-existent item
        item1.next_item_id = uuid.uuid4()

        items = [item1, item2]
        result = get_items_sorted_by_tier_set(items)

        # Should return items (unsorted due to broken link)
        assert len(result) == 2


class TestBuildListResponse:
    """Tests for build_list_response function."""

    def test_build_response_without_items(self):
        """Test building response without items."""

        class MockList:
            list_id = uuid.uuid4()
            user_id = uuid.uuid4()
            title = "Test List"
            description = "Test description"
            created_at = datetime.now()
            updated_at = datetime.now()

        result = build_list_response(MockList())
        assert result["title"] == "Test List"
        assert result["description"] == "Test description"
        assert "items" not in result

    def test_build_response_with_items(self):
        """Test building response with items."""

        class MockList:
            list_id = uuid.uuid4()
            user_id = uuid.uuid4()
            title = "Test List"
            description = "Test description"
            created_at = datetime.now()
            updated_at = datetime.now()

        items = [{"name": "Item 1"}, {"name": "Item 2"}]
        result = build_list_response(MockList(), items=items)
        assert result["title"] == "Test List"
        assert "items" in result
        assert len(result["items"]) == 2

    def test_build_response_with_empty_items(self):
        """Test building response with empty items list."""

        class MockList:
            list_id = uuid.uuid4()
            user_id = uuid.uuid4()
            title = "Test List"
            description = "Test description"
            created_at = datetime.now()
            updated_at = datetime.now()

        result = build_list_response(MockList(), items=[])
        assert "items" in result
        assert result["items"] == []


class TestBuildListSimpleResponse:
    """Tests for build_list_simple_response function."""

    def test_build_simple_response(self):
        """Test building simple response with stats."""

        class MockList:
            list_id = uuid.uuid4()
            user_id = uuid.uuid4()
            title = "Test List"
            description = "Test description"
            created_at = datetime.now()
            updated_at = datetime.now()

        # Row format: (ListModel, item_count, tier_s, tier_a, tier_b, tier_c, tier_d, tier_f)
        row = (MockList(), 10, 2, 3, 2, 1, 1, 1)
        result = build_list_simple_response(row)

        assert result["title"] == "Test List"
        assert result["item_count"] == 10
        assert result["tier_distribution"]["S"] == 2
        assert result["tier_distribution"]["A"] == 3
        assert result["tier_distribution"]["B"] == 2
        assert result["tier_distribution"]["C"] == 1
        assert result["tier_distribution"]["D"] == 1
        assert result["tier_distribution"]["F"] == 1

    def test_build_simple_response_with_none_values(self):
        """Test building simple response with None counts."""

        class MockList:
            list_id = uuid.uuid4()
            user_id = uuid.uuid4()
            title = "Test List"
            description = "Test description"
            created_at = datetime.now()
            updated_at = datetime.now()

        # Row with None values (from LEFT JOINs with no items)
        row = (MockList(), None, None, None, None, None, None, None)
        result = build_list_simple_response(row)

        assert result["item_count"] == 0
        assert result["tier_distribution"]["S"] == 0
        assert result["tier_distribution"]["A"] == 0
        assert result["tier_distribution"]["B"] == 0
        assert result["tier_distribution"]["C"] == 0
        assert result["tier_distribution"]["D"] == 0
        assert result["tier_distribution"]["F"] == 0

    def test_build_simple_response_partial_tiers(self):
        """Test building simple response with some tiers having items."""

        class MockList:
            list_id = uuid.uuid4()
            user_id = uuid.uuid4()
            title = "Test List"
            description = "Test description"
            created_at = datetime.now()
            updated_at = datetime.now()

        # Only S and A tiers have items
        row = (MockList(), 5, 3, 2, None, None, None, None)
        result = build_list_simple_response(row)

        assert result["item_count"] == 5
        assert result["tier_distribution"]["S"] == 3
        assert result["tier_distribution"]["A"] == 2
        assert result["tier_distribution"]["B"] == 0
        assert result["tier_distribution"]["C"] == 0
        assert result["tier_distribution"]["D"] == 0
        assert result["tier_distribution"]["F"] == 0
