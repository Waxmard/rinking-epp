import 'package:flutter/foundation.dart';
import '../models/list_model.dart';
import '../services/list_service.dart';

class ListProvider extends ChangeNotifier {
  final ListService _listService = ListService();
  
  bool _isLoading = false;
  String? _error;
  TierList? _recentList;
  List<TierList> _lists = [];
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  TierList? get recentList => _recentList;
  List<TierList> get lists => _lists;
  
  // Set auth token for the list service
  void setAuthToken(String token) {
    _listService.setAuthToken(token);
  }
  
  // Initialize by fetching initial data
  Future<void> initialize() async {
    await Future.wait([
      fetchRecentList(),
      fetchLists(),
    ]);
  }
  
  // Fetch the user's most recent list
  Future<void> fetchRecentList() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _recentList = await _listService.getRecentList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Fetch all user lists
  Future<void> fetchLists({int skip = 0, int limit = 20, bool refresh = false}) async {
    _isLoading = true;
    if (refresh) {
      _lists = [];
    }
    notifyListeners();
    
    try {
      final fetchedLists = await _listService.getLists(skip: skip, limit: limit);
      
      if (refresh || skip == 0) {
        _lists = fetchedLists;
      } else {
        _lists = [..._lists, ...fetchedLists];
      }
      
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Get a specific list with items
  Future<TierListWithItems?> getList(String listId, {String? tier}) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final list = await _listService.getList(listId, tier: tier);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return list;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
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
    _isLoading = true;
    notifyListeners();
    
    try {
      final newList = await _listService.createList(
        title: title,
        description: description,
        isPublic: isPublic,
        initialItems: initialItems,
      );
      
      if (newList != null) {
        // Update the lists and recent list
        _recentList = newList;
        _lists = [newList, ..._lists];
      }
      
      _error = null;
      _isLoading = false;
      notifyListeners();
      return newList;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  // Update a list
  Future<TierList?> updateList({
    required String listId,
    required String title,
    required String description,
    required bool isPublic,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final updatedList = await _listService.updateList(
        listId: listId,
        title: title,
        description: description,
        isPublic: isPublic,
      );
      
      if (updatedList != null) {
        // Update in the lists array
        final index = _lists.indexWhere((list) => list.listId == listId);
        if (index != -1) {
          _lists[index] = updatedList;
        }
        
        // Update recent list if it's the same
        if (_recentList?.listId == listId) {
          _recentList = updatedList;
        }
      }
      
      _error = null;
      _isLoading = false;
      notifyListeners();
      return updatedList;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  // Delete a list
  Future<bool> deleteList(String listId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final success = await _listService.deleteList(listId);
      
      if (success) {
        // Remove from lists array
        _lists.removeWhere((list) => list.listId == listId);
        
        // Clear recent list if it's the same
        if (_recentList?.listId == listId) {
          _recentList = null;
        }
      }
      
      _error = null;
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Clear any error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}