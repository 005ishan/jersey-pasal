import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerseypasal/core/services/hive/hive_service.dart';
import 'package:jerseypasal/core/services/storage/user_session_service.dart';
import 'package:jerseypasal/features/auth/data/datasources/auth_datasource.dart';
import 'package:jerseypasal/features/auth/data/models/auth_hive_model.dart';

final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  final userSessionService = ref.read(userSessionServiceProvider);
  return AuthLocalDatasource(
    hiveService: hiveService,
    userSessionService: userSessionService,
  );
});

class AuthLocalDatasource implements IAuthLocalDatasource {
  final HiveService _hiveService;
  final UserSessionService _userSessionService;

  AuthLocalDatasource({
    required HiveService hiveService,
    required UserSessionService userSessionService,
  }) : _hiveService = hiveService,
       _userSessionService = userSessionService;

  @override
  Future<bool> register(AuthHiveModel model) async {
    final existing = _hiveService.getUserByEmail(model.email);
    if (existing != null) return false;

    final saved = await _hiveService.registerUser(model);
    return saved != null;
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    try {
      final user = await _hiveService.loginUser(email, password);
      // user ko details lai shared prefs ma save garne
      if (user != null) {
        await _userSessionService.saveUserSession(
          userId: user.authId!,
          email: user.email,
          profilePicture: user.profilePicture ?? "",
        );
      }
      return user;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _hiveService.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  AuthHiveModel? getUserByEmail(String email) {
    try {
      return _hiveService.getUserByEmail(email);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    try {
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isEmailExists(String email) async {
    try {
      return _hiveService.isEmailExists(email);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      return await _hiveService.resetPassword(
        email: email,
        newPassword: newPassword,
      );
    } catch (e) {
      return false;
    }
  }
}
