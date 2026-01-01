import 'package:jerseypasal/features/auth/data/models/auth_hive_model.dart';

abstract interface class IAuthDatasource {
  Future<bool> register(AuthHiveModel model);
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel?> getCurrentUser();
  Future<bool> logout();

  //get email exists
  Future<bool> isEmailExists(String email);
  AuthHiveModel? getUserByEmail(String email);
  /// Reset password
  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  });
}
