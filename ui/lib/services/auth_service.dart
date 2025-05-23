import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../constants/auth_constants.dart';

/// Authentication result status
enum AuthResultStatus {
  success,
  error,
  cancelled,
}

/// Authentication result
class AuthResult {
  final AuthResultStatus status;
  final String? message;
  final Map<String, dynamic>? userData;
  final String? token;

  AuthResult({
    required this.status,
    this.message,
    this.userData,
    this.token,
  });

  bool get isSuccess => status == AuthResultStatus.success;
}

/// Service that handles authentication operations
class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: AuthConstants.googleClientId,
  );
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  
  factory AuthService() => _instance;
  
  AuthService._internal();
  
  /// Sign in with Google
  Future<AuthResult> signInWithGoogle() async {
    // Mock authentication for development
    if (AuthConstants.environment == 'development') {
      // Simulate loading delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Store mock token
      await _secureStorage.write(
        key: AuthConstants.authTokenKey,
        value: 'mock-dev-token-${DateTime.now().millisecondsSinceEpoch}',
      );
      
      // Return successful mock result
      return AuthResult(
        status: AuthResultStatus.success,
        userData: {
          'email': 'dev@tiernerd.com',
          'displayName': 'Development User',
          'photoUrl': 'assets/images/gengar.png',
        },
        token: 'mock-token',
      );
    }
    
    // Real authentication for production/staging
    try {
      // Start the Google Sign-In process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      // If the user cancels the sign-in process
      if (googleUser == null) {
        return AuthResult(
          status: AuthResultStatus.cancelled,
          message: 'Sign in was cancelled',
        );
      }
      
      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Here, you would typically send these tokens to your backend for verification
      // and to create or retrieve the user account
      final response = await _authenticateWithBackend(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
        email: googleUser.email,
        displayName: googleUser.displayName,
        photoUrl: googleUser.photoUrl,
      );
      
      if (response.statusCode != 200) {
        return AuthResult(
          status: AuthResultStatus.error,
          message: 'Backend authentication failed: ${response.reasonPhrase}',
        );
      }
      
      // Parse response and extract token
      final responseData = jsonDecode(response.body);
      final token = responseData['access_token'];
      
      // Store token securely
      await _secureStorage.write(
        key: AuthConstants.authTokenKey,
        value: token,
      );
      
      // Return successful result with user data
      return AuthResult(
        status: AuthResultStatus.success,
        userData: {
          'email': googleUser.email,
          'displayName': googleUser.displayName,
          'photoUrl': googleUser.photoUrl,
        },
        token: token,
      );
      
    } catch (e) {
      return AuthResult(
        status: AuthResultStatus.error,
        message: 'Sign in error: ${e.toString()}',
      );
    }
  }
  
  /// Sign out the current user
  Future<void> signOut() async {
    // Sign out from Google
    await _googleSignIn.signOut();
    
    // Remove stored token
    await _secureStorage.delete(key: AuthConstants.authTokenKey);
  }
  
  /// Check if the user is already signed in
  Future<bool> isSignedIn() async {
    // Check if we have a token
    final token = await _secureStorage.read(key: AuthConstants.authTokenKey);
    return token != null;
  }
  
  /// Get the stored authentication token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: AuthConstants.authTokenKey);
  }
  
  /// Send authentication details to the backend
  Future<http.Response> _authenticateWithBackend({
    String? idToken,
    String? accessToken,
    required String email,
    String? displayName,
    String? photoUrl,
  }) async {
    // Construct the API endpoint
    final url = Uri.parse('${AuthConstants.apiBaseUrl}${AuthConstants.googleAuthEndpoint}');
    
    // Send the request to your backend
    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id_token': idToken,
        'access_token': accessToken,
        'email': email,
        'display_name': displayName ?? '',
        'photo_url': photoUrl ?? '',
      }),
    );
  }
}