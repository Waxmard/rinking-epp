import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

/// Provider for authentication state
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _userData;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get userData => _userData;
  
  /// Initialize auth state
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _isAuthenticated = await _authService.isSignedIn();
      // If authenticated, we could load user profile here
      
      _error = null;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _authService.signInWithGoogle();
      
      if (result.isSuccess) {
        _isAuthenticated = true;
        _userData = result.userData;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = result.message;
        _isAuthenticated = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _authService.signOut();
      _isAuthenticated = false;
      _userData = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Clear any error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}