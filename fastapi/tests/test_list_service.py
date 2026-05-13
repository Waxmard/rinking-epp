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
    position: str | None = "a0",
) -> ItemModel:
    """Create a mock item for testing."""
    return ItemModel(
        item_id=uuid.uuid4(),
        list_id=uuid.uuid4(),
        name=name,
        description=f"Description for {name}",
        image_url=f"https://example.com/{name}.jpg",
        position=position,
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
        item = create_mock_item("Only Item", tier_set="good", position="a0")
        result = get_items_sorted_by_tier_set([item])
        assert len(result) == 1
        assert result[0] is item

    def test_sort_items_by_position_single_tier_set(self):
        """Test sorting items by position within a single tier_set."""
        item1 = create_mock_item("Item 1", tier_set="good", position="a0")
        item2 = create_mock_item("Item 2", tier_set="good", position="a1")
        item3 = create_mock_item("Item 3", tier_set="good", position="a2")

        # Pass in random order
        items = [item3, item1, item2]
        result = get_items_sorted_by_tier_set(items)

        assert len(result) == 3
        assert result[0] is item1
        assert result[1] is item2
        assert result[2] is item3

    def test_sort_multiple_tier_sets(self):
        """Test sorting items across multiple tier_sets."""
        good1 = create_mock_item("Good 1", tier_set="good", position="a0")
        good2 = create_mock_item("Good 2", tier_set="good", position="a1")
        mid1 = create_mock_item("Mid 1", tier_set="mid", position="a0")

        items = [good2, mid1, good1]
        result = get_items_sorted_by_tier_set(items)

        # Should have all 3 items
        assert len(result) == 3

    def test_sort_with_unranked_items(self):
        """Test that items without position go at the end."""
        ranked = create_mock_item("Ranked", tier_set="good", position="a0")
        unranked = create_mock_item("Unranked", tier_set="good", position=None)

        items = [unranked, ranked]
        result = get_items_sorted_by_tier_set(items)

        assert len(result) == 2
        assert result[0] is ranked  # Ranked item first
        assert result[1] is unranked  # Unranked item last


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
