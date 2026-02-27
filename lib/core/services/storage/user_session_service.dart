import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// ─────────────────────────────────────────────
/// PROVIDERS
/// ─────────────────────────────────────────────

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'SharedPreferences must be initialized in main.dart',
  );
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  return UserSessionService(
    prefs: ref.read(sharedPreferencesProvider),
    secureStorage: ref.read(secureStorageProvider),
  );
});

// reactive name provider for AppBar + Profile Screen
final userNameProvider = StateProvider<String>((ref) {
  final session = ref.read(userSessionServiceProvider);
  return session.getUserName() ??
      (session.getUserEmail()?.split('@')[0] ?? 'Customer');
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
  static const String _keyUserName = 'user_name'; // ✅ defined here

  // SecureStorage key
  static const String _keyAuthToken = 'auth_token';

  /// ───────── SAVE SESSION ─────────
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
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserEmail);
    // ✅ _keyUserName intentionally NOT removed — name persists after logout

    await _secureStorage.delete(key: _keyAuthToken);
  }

  /// ───────── GETTERS ─────────
  bool isLoggedIn() => _prefs.getBool(_keyIsLoggedIn) ?? false;

  String? getUserId() => _prefs.getString(_keyUserId);

  String? getUserEmail() => _prefs.getString(_keyUserEmail);

  String? getUserProfileImage() => _prefs.getString(_keyUserProfileImage);

  String? getUserName() => _prefs.getString(_keyUserName);

  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: _keyAuthToken);
  }

  /// ───────── NAME ─────────
  Future<void> saveUserName(String name) async {
    await _prefs.setString(_keyUserName, name);
  }
}