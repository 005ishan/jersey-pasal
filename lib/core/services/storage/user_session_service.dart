import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Shared prefs provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  // async initialization will happen in main.dart
  throw UnimplementedError(
    "Shared prefs will be initialized in main.dart",
  );
});

// UserSessionService provider
final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  return UserSessionService(prefs: ref.read(sharedPreferencesProvider));
});

class UserSessionService {
  final SharedPreferences _prefs;

  UserSessionService({required SharedPreferences prefs}) : _prefs = prefs;

  // Keys for storing data
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyAuthToken = 'auth_token';
  static const String _keyUserProfileImage = 'user_profile_image';

  // Store user session data
  Future<void> saveUserSession({
    required String userId,
    required String email,
    String? profilePicture,
    String? token, // fixed: now you can pass token
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyUserEmail, email);

    if (profilePicture != null) {
      await _prefs.setString(_keyUserProfileImage, profilePicture);
    }

    if (token != null) {
      await _prefs.setString(_keyAuthToken, token); // <-- save the token
    }
  }

  // Clear user session data
  Future<void> clearUserSession() async {
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyAuthToken);
    await _prefs.remove(_keyUserProfileImage);
  }

  // Getters
  bool isLoggedIn() => _prefs.getBool(_keyIsLoggedIn) ?? false;
  String? getUserId() => _prefs.getString(_keyUserId);
  String? getUserEmail() => _prefs.getString(_keyUserEmail);
  String? getUserProfileImage() => _prefs.getString(_keyUserProfileImage);
  String? getAuthToken() => _prefs.getString(_keyAuthToken); // <-- added getter for token
}
