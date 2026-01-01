import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerseypasal/core/error/failures.dart';
import 'package:jerseypasal/features/auth/data/datasources/auth_datasource.dart';
import 'package:jerseypasal/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:jerseypasal/features/auth/data/models/auth_hive_model.dart';
import 'package:jerseypasal/features/auth/domain/entities/auth_entity.dart';
import 'package:jerseypasal/features/auth/domain/repositories/auth_repository.dart';

// Provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authDatasource = ref.read(authLocalDatasourceProvider);
  return AuthRepository(authDatasource: authDatasource);
});

class AuthRepository implements IAuthRepository {
  final IAuthDatasource _authDatasource;

  AuthRepository({required IAuthDatasource authDatasource})
    : _authDatasource = authDatasource;

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final user = await _authDatasource.getCurrentUser();
      if (user == null) {
        return Left(LocalDatabaseFailure(message: "User not found"));
      }
      return Right(user.toEntity());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final user = await _authDatasource.login(email, password);
      if (user == null) {
        return Left(LocalDatabaseFailure(message: "Invalid credentials"));
      }
      return Right(user.toEntity());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authDatasource.logout();
      if (!result) {
        return Left(LocalDatabaseFailure(message: "Logout Failure"));
      }
      return Right(result);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    try {
      final model = _authDatasource.getUserByEmail(entity.email);

      if (model != null) {
        return Left(LocalDatabaseFailure(message: "Email already exists"));
      }

      final result = await _authDatasource.register(
        AuthHiveModel.fromEntity(entity),
      );
      if (!result) {
        return Left(LocalDatabaseFailure(message: "Failed to register user"));
      }

      return Right(true);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, bool>> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      final result = await _authDatasource.resetPassword(
        email: email,
        newPassword: newPassword,
      );

      if (!result) {
        return Left(LocalDatabaseFailure(message: "User not found"));
      }

      return Right(true);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
