import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// ─────────────────────────────────────────────
/// PROVIDERS
/// ─────────────────────────────────────────────

// SharedPreferences provider (initialized in main.dart)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'SharedPreferences must be initialized in main.dart',
  );
});

// SecureStorage provider
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

// UserSessionService provider
final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  return UserSessionService(
    prefs: ref.read(sharedPreferencesProvider),
    secureStorage: ref.read(secureStorageProvider),
  );
});

/// ─────────────────────────────────────────────
/// USER SESSION SERVICE
/// ─────────────────────────────────────────────

class UserSessionService {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  UserSessionService({
    required SharedPreferences prefs,
    required FlutterSecureStorage secureStorage,
  }) : _prefs = prefs,
       _secureStorage = secureStorage;

  // SharedPreferences keys
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserProfileImage = 'user_profile_image';

  // SecureStorage key
  static const String _keyAuthToken = 'auth_token';

  /// ───────── SAVE SESSION (LOGIN / UPDATE PROFILE) ─────────
  Future<void> saveUserSession({
    required String userId,
    required String email,
    String? profilePicture,
    String? token,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyUserEmail, email);

    if (profilePicture != null) {
      await _prefs.setString(_keyUserProfileImage, profilePicture);
    }

    if (token != null) {
      await _secureStorage.write(key: _keyAuthToken, value: token);
    }
  }

  /// ───────── LOGOUT / CLEAR SESSION ─────────
  Future<void> clearSession() async {
    // Only clear auth-related keys, not profile picture
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserEmail);

    await _secureStorage.delete(key: _keyAuthToken);

    // DO NOT remove _keyUserProfileImage
  }

  /// ───────── GETTERS ─────────
  bool isLoggedIn() => _prefs.getBool(_keyIsLoggedIn) ?? false;

  String? getUserId() => _prefs.getString(_keyUserId);

  String? getUserEmail() => _prefs.getString(_keyUserEmail);

  String? getUserProfileImage() => _prefs.getString(_keyUserProfileImage);

  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: _keyAuthToken);
  }
}
