import 'dart:async';
import 'dart:math';
import '../models/list_model.dart';

/// A mock implementation of the list service for development
class MockListService {
  /// In-memory mock data storage
  final List<TierList> _mockLists = [];
  final Map<String, List<TierListItem>> _mockItems = {};
  final Random _random = Random();

  /// Constructor with optional seed data
  MockListService() {
    _seedMockData();
  }

  /// Generate a unique ID (simple implementation for mock data)
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        _random.nextInt(1000).toString();
  }

  /// Seed the mock with initial data
  void _seedMockData() {
    // Create a few lists
    final list1Id = _generateId();
    final list2Id = _generateId();
    final list3Id = _generateId();
    final list4Id = _generateId();
    
    final userId = "mock_user_123";
    
    // List 1: Best Anime Series
    final list1 = TierList(
      listId: list1Id,
      userId: userId,
      title: "Best Anime Series",
      description: "My personal ranking of anime shows I've watched",
      isPublic: true,
      itemCount: 15,
      tierCounts: {
        'S': 2,
        'A': 3,
        'B': 4,
        'C': 3,
        'D': 2,
        'F': 1,
      },
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    );
    
    // List 2: Top Video Games 2023
    final list2 = TierList(
      listId: list2Id,
      userId: userId,
      title: "Top Video Games 2023",
      description: "Ranking the best games released this year",
      isPublic: true,
      itemCount: 20,
      tierCounts: {
        'S': 3,
        'A': 5,
        'B': 6,
        'C': 4,
        'D': 2,
        'F': 0,
      },
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    );
    
    // List 3: MCU Movies Ranked
    final list3 = TierList(
      listId: list3Id,
      userId: userId,
      title: "MCU Movies Ranked",
      description: "All Marvel Cinematic Universe films in order of greatness",
      isPublic: true,
      itemCount: 30,
      tierCounts: {
        'S': 4,
        'A': 8,
        'B': 10,
        'C': 5,
        'D': 2,
        'F': 1,
      },
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    );
    
    // List 4: Best Restaurants in Town
    final list4 = TierList(
      listId: list4Id,
      userId: userId,
      title: "Best Restaurants in Town",
      description: "My favorite places to eat",
      isPublic: false,
      itemCount: 12,
      tierCounts: {
        'S': 2,
        'A': 3,
        'B': 3,
        'C': 2,
        'D': 1,
        'F': 1,
      },
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
    );
    
    // Add lists to in-memory storage
    _mockLists.addAll([list1, list2, list3, list4]);
    
    // Create items for list1 (Anime)
    _mockItems[list1Id] = [
      TierListItem(
        itemId: _generateId(),
        listId: list1Id,
        name: "Attack on Titan",
        description: "A dark fantasy series about humanity's fight against man-eating giants",
        position: 1,
        rating: 9.8,
        tier: "S",
        createdAt: DateTime.now().subtract(const Duration(days: 29)),
        updatedAt: DateTime.now().subtract(const Duration(days: 29)),
      ),
      TierListItem(
        itemId: _generateId(),
        listId: list1Id,
        name: "Fullmetal Alchemist: Brotherhood",
        description: "Two brothers search for the Philosopher's Stone",
        position: 2,
        rating: 9.7,
        tier: "S",
        createdAt: DateTime.now().subtract(const Duration(days: 29)),
        updatedAt: DateTime.now().subtract(const Duration(days: 29)),
      ),
      TierListItem(
        itemId: _generateId(),
        listId: list1Id,
        name: "Demon Slayer",
        description: "A boy fights demons after his family is slaughtered",
        position: 3,
        rating: 9.2,
        tier: "A",
        createdAt: DateTime.now().subtract(const Duration(days: 28)),
        updatedAt: DateTime.now().subtract(const Duration(days: 28)),
      ),
      TierListItem(
        itemId: _generateId(),
        listId: list1Id,
        name: "My Hero Academia",
        description: "A quirkless boy inherits a powerful quirk",
        position: 4,
        rating: 9.0,
        tier: "A",
        createdAt: DateTime.now().subtract(const Duration(days: 28)),
        updatedAt: DateTime.now().subtract(const Duration(days: 28)),
      ),
      TierListItem(
        itemId: _generateId(),
        listId: list1Id,
        name: "Death Note",
        description: "A high school student discovers a supernatural notebook",
        position: 5,
        rating: 8.9,
        tier: "A",
        createdAt: DateTime.now().subtract(const Duration(days: 27)),
        updatedAt: DateTime.now().subtract(const Duration(days: 27)),
      ),
    ];
    
    // Add more items to other lists if needed for testing...
  }

  /// AUTH METHODS

  /// Set authentication token (mock method - doesn't do anything)
  void setAuthToken(String token) {
    // No actual action needed for mock
    print('Mock: Auth token set (not actually used in mock service)');
  }

  /// API METHODS

  /// Get the most recent list
  Future<TierList?> getRecentList() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (_mockLists.isEmpty) {
      return null;
    }
    
    // Sort by updatedAt and return the most recent
    _mockLists.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return _mockLists.first;
  }

  /// Get all lists with pagination
  Future<List<TierList>> getLists({int skip = 0, int limit = 20}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (_mockLists.isEmpty) {
      return [];
    }
    
    // Sort lists by updated date (newest first)
    final sortedLists = List<TierList>.from(_mockLists)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    
    // Apply pagination
    final end = skip + limit > sortedLists.length ? sortedLists.length : skip + limit;
    if (skip >= sortedLists.length) {
      return [];
    }
    
    return sortedLists.sublist(skip, end);
  }

  /// Get a specific list with its items
  Future<TierListWithItems?> getList(String listId, {String? tier}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1200));
    
    // Find the list
    final listIndex = _mockLists.indexWhere((list) => list.listId == listId);
    if (listIndex == -1) {
      return null;
    }
    
    final list = _mockLists[listIndex];
    
    // Get items for this list
    final items = _mockItems[listId] ?? [];
    
    // Filter by tier if specified
    final filteredItems = tier != null 
        ? items.where((item) => item.tier == tier).toList()
        : items;
    
    return TierListWithItems(
      listId: list.listId,
      userId: list.userId,
      title: list.title,
      description: list.description,
      isPublic: list.isPublic,
      createdAt: list.createdAt,
      updatedAt: list.updatedAt,
      tierRequested: tier,
      items: filteredItems,
      tierCounts: list.tierCounts,
    );
  }

  /// Create a new list
  Future<TierList?> createList({
    required String title,
    required String description,
    required bool isPublic,
    List<Map<String, dynamic>>? initialItems,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));
    
    final listId = _generateId();
    final userId = "mock_user_123"; // Mock user ID
    
    // Create empty tier counts
    final tierCounts = {
      'S': 0,
      'A': 0,
      'B': 0,
      'C': 0,
      'D': 0,
      'F': 0,
      'unranked': initialItems?.length ?? 0,
    };
    
    // Create the new list
    final newList = TierList(
      listId: listId,
      userId: userId,
      title: title,
      description: description,
      isPublic: isPublic,
      itemCount: initialItems?.length ?? 0,
      tierCounts: tierCounts,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Add it to the mock data
    _mockLists.add(newList);
    
    // Create items if any were provided
    if (initialItems != null && initialItems.isNotEmpty) {
      final items = <TierListItem>[];
      
      for (var i = 0; i < initialItems.length; i++) {
        final item = initialItems[i];
        items.add(
          TierListItem(
            itemId: _generateId(),
            listId: listId,
            name: item['name'],
            description: item['description'] ?? '',
            imageUrl: item['image_url'],
            position: i + 1,
            rating: 0, // Default rating for new items
            tier: null, // New items are unranked
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }
      
      // Store the items
      _mockItems[listId] = items;
    } else {
      _mockItems[listId] = [];
    }
    
    return newList;
  }

  /// Update a list's metadata
  Future<TierList?> updateList({
    required String listId,
    required String title,
    required String description,
    required bool isPublic,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Find the list
    final listIndex = _mockLists.indexWhere((list) => list.listId == listId);
    if (listIndex == -1) {
      return null;
    }
    
    // Get the existing list
    final existingList = _mockLists[listIndex];
    
    // Create updated list
    final updatedList = TierList(
      listId: existingList.listId,
      userId: existingList.userId,
      title: title,
      description: description,
      isPublic: isPublic,
      itemCount: existingList.itemCount,
      tierCounts: existingList.tierCounts,
      createdAt: existingList.createdAt,
      updatedAt: DateTime.now(), // Update the timestamp
    );
    
    // Update the list in our mock data
    _mockLists[listIndex] = updatedList;
    
    return updatedList;
  }

  /// Delete a list
  Future<bool> deleteList(String listId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Find the list
    final listIndex = _mockLists.indexWhere((list) => list.listId == listId);
    if (listIndex == -1) {
      return false;
    }
    
    // Remove the list
    _mockLists.removeAt(listIndex);
    
    // Remove any associated items
    _mockItems.remove(listId);
    
    return true;
  }
}