class TierList {
  final String listId;
  final String userId;
  final String title;
  final String description;
  final bool isPublic;
  final int itemCount;
  final Map<String, int> tierCounts;
  final DateTime createdAt;
  final DateTime updatedAt;

  TierList({
    required this.listId,
    required this.userId,
    required this.title,
    required this.description,
    required this.isPublic,
    required this.itemCount,
    required this.tierCounts,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TierList.fromJson(Map<String, dynamic> json) {
    return TierList(
      listId: json['list_id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      isPublic: json['is_public'],
      itemCount: json['item_count'],
      tierCounts: Map<String, int>.from(json['tier_counts']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'list_id': listId,
      'user_id': userId,
      'title': title,
      'description': description,
      'is_public': isPublic,
      'item_count': itemCount,
      'tier_counts': tierCounts,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class TierListItem {
  final String itemId;
  final String listId;
  final String name;
  final String description;
  final String? imageUrl;
  final int position;
  final double rating;
  final String? tier; // S, A, B, C, D, F, or null for unranked
  final DateTime createdAt;
  final DateTime updatedAt;

  TierListItem({
    required this.itemId,
    required this.listId,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.position,
    required this.rating,
    this.tier,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TierListItem.fromJson(Map<String, dynamic> json) {
    return TierListItem(
      itemId: json['item_id'],
      listId: json['list_id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['image_url'],
      position: json['position'],
      rating: json['rating'].toDouble(),
      tier: json['tier'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'list_id': listId,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'position': position,
      'rating': rating,
      'tier': tier,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class TierListWithItems {
  final String listId;
  final String userId;
  final String title;
  final String description;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? tierRequested;
  final List<TierListItem> items;
  final Map<String, int> tierCounts;

  TierListWithItems({
    required this.listId,
    required this.userId,
    required this.title,
    required this.description,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
    this.tierRequested,
    required this.items,
    required this.tierCounts,
  });

  factory TierListWithItems.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>;

    return TierListWithItems(
      listId: json['list_id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      isPublic: json['is_public'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      tierRequested: json['tier_requested'],
      items: itemsJson.map((itemJson) => TierListItem.fromJson(itemJson)).toList(),
      tierCounts: Map<String, int>.from(json['tier_counts']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'list_id': listId,
      'user_id': userId,
      'title': title,
      'description': description,
      'is_public': isPublic,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'tier_requested': tierRequested,
      'items': items.map((item) => item.toJson()).toList(),
      'tier_counts': tierCounts,
    };
  }
}
