import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:jerseypasal/core/constants/hive_table_constant.dart';
import 'package:jerseypasal/features/auth/data/models/auth_hive_model.dart';
import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = Provider<HiveService>((ref) => HiveService());

class HiveService {
  // Initialize Hive
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    Hive.init('${directory.path}/${HiveTableConstant.dbName}');
    _registerAdapters();
    await _openBoxes();
  }

  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }

  Future<void> _openBoxes() async { 
    if (!Hive.isBoxOpen(HiveTableConstant.authTable)) {
      await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
    }
  }

  Future<void> close() async => Hive.close();

  // Safe getter for auth box
  Box<AuthHiveModel> get _authBox {
    if (!Hive.isBoxOpen(HiveTableConstant.authTable)) {
      throw Exception(
          "Hive box '${HiveTableConstant.authTable}' not opened. Call init() first.");
    }
    return Hive.box<AuthHiveModel>(HiveTableConstant.authTable);
  }

  // CRUD Operations
  Future<AuthHiveModel> registerUser(AuthHiveModel model) async {
    await _authBox.put(model.authId, model);
    return model;
  }

  Future<AuthHiveModel?> loginUser(String email, String password) async {
    final users = _authBox.values.where(
      (user) => user.email == email && user.password == password,
    );
    return users.isNotEmpty ? users.first : null;
  }

  AuthHiveModel? getCurrentUser(String authId) => _authBox.get(authId);

  bool isEmailExists(String email) =>
      _authBox.values.any((user) => user.email == email);

  AuthHiveModel? getUserByEmail(String email) {
    try {
      return _authBox.values.firstWhere((user) => user.email == email);
    } catch (_) {
      return null;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final user = getUserByEmail(email);
    if (user == null) return false;

    final updatedUser = user.copyWith(password: newPassword);
    await _authBox.put(user.authId, updatedUser);
    return true;
  }
}

// Add copyWith extension to AuthHiveModel
extension AuthHiveModelCopy on AuthHiveModel {
  AuthHiveModel copyWith({
    String? fullName,
    String? email,
    String? username,
    String? password,
    String? profilePicture,
  }) {
    return AuthHiveModel(
      authId: authId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }
}
