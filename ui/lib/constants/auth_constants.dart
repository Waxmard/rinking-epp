import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Authentication constants for the TierNerd app
class AuthConstants {
  /// Google OAuth client ID from environment variables
  static String get googleClientId =>
      dotenv.env['GOOGLE_CLIENT_ID'] ?? '';

  /// Base API URL for authentication endpoints
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://api.tiernerd.com';

  /// Authentication endpoints
  static String get googleAuthEndpoint =>
      dotenv.env['API_GOOGLE_AUTH_ENDPOINT'] ?? '/auth/google';

  /// Environment (development, staging, production)
  static String get environment =>
      dotenv.env['ENV'] ?? 'development';

  /// Token storage key
  static const String authTokenKey = 'tiernerd_auth_token';
}