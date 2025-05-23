import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/list_model.dart';

class ListService {
  final String? apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api/v1';
  late final http.Client _client;
  String? _authToken;

  ListService() {
    _client = http.Client();
  }

  // Set the auth token for API requests
  void setAuthToken(String token) {
    _authToken = token;
  }

  // Get headers for API requests
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }

  // Get the user's most recent list
  Future<TierList?> getRecentList() async {
    try {
      final response = await _client.get(
        Uri.parse('$apiBaseUrl/lists/recent'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TierList.fromJson(data);
      } else if (response.statusCode == 404) {
        // No lists found
        return null;
      } else {
        throw Exception('Failed to get recent list: ${response.statusCode}');
      }
    } catch (e) {
      // For now just return null if there's an error
      // TODO: Better error handling
      print('Error getting recent list: $e');
      return null;
    }
  }

  // Get all lists for the current user with pagination
  Future<List<TierList>> getLists({int skip = 0, int limit = 20}) async {
    try {
      final response = await _client.get(
        Uri.parse('$apiBaseUrl/lists?skip=$skip&limit=$limit'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => TierList.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get lists: ${response.statusCode}');
      }
    } catch (e) {
      // For now just return empty list if there's an error
      // TODO: Better error handling
      print('Error getting lists: $e');
      return [];
    }
  }

  // Get a specific list with its items
  Future<TierListWithItems?> getList(String listId, {String? tier}) async {
    try {
      final String url = tier != null 
          ? '$apiBaseUrl/lists/$listId?tier=$tier'
          : '$apiBaseUrl/lists/$listId';
      
      final response = await _client.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TierListWithItems.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to get list: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting list: $e');
      return null;
    }
  }

  // Create a new list
  Future<TierList?> createList({
    required String title,
    required String description,
    required bool isPublic,
    List<Map<String, dynamic>>? initialItems,
  }) async {
    try {
      final body = json.encode({
        'title': title,
        'description': description,
        'is_public': isPublic,
        'initial_items': initialItems ?? [],
      });

      final response = await _client.post(
        Uri.parse('$apiBaseUrl/lists'),
        headers: _headers,
        body: body,
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return TierList.fromJson(data);
      } else {
        throw Exception('Failed to create list: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating list: $e');
      return null;
    }
  }

  // Update a list's metadata
  Future<TierList?> updateList({
    required String listId,
    required String title,
    required String description,
    required bool isPublic,
  }) async {
    try {
      final body = json.encode({
        'title': title,
        'description': description,
        'is_public': isPublic,
      });

      final response = await _client.put(
        Uri.parse('$apiBaseUrl/lists/$listId'),
        headers: _headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TierList.fromJson(data);
      } else {
        throw Exception('Failed to update list: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating list: $e');
      return null;
    }
  }

  // Delete a list
  Future<bool> deleteList(String listId) async {
    try {
      final response = await _client.delete(
        Uri.parse('$apiBaseUrl/lists/$listId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete list: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting list: $e');
      return false;
    }
  }
}