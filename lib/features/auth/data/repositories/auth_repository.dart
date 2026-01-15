import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerseypasal/core/error/failures.dart';
import 'package:jerseypasal/core/services/connectivity/network_info.dart';
import 'package:jerseypasal/features/auth/data/datasources/auth_datasource.dart';
import 'package:jerseypasal/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:jerseypasal/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:jerseypasal/features/auth/data/models/auth_api_model.dart';
import 'package:jerseypasal/features/auth/data/models/auth_hive_model.dart';
import 'package:jerseypasal/features/auth/domain/entities/auth_entity.dart';
import 'package:jerseypasal/features/auth/domain/repositories/auth_repository.dart';

// Provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authDatasource = ref.read(authLocalDatasourceProvider);
  final AuthRemoteDatasource = ref.read(authRemoteDataSourceProvider);
  final NetworkInfo = ref.read(networkInfoProvider);
  return AuthRepository(
    authDatasource: authDatasource,
    authRemoteDataSource: AuthRemoteDatasource,
    networkInfo: NetworkInfo,
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDatasource _authDatasource;
  final IAuthRemoteDataSource _authRemoteDataSource;
  final NetworkInfo _networkInfo;

  AuthRepository({
    required IAuthLocalDatasource authDatasource,
    required IAuthRemoteDataSource authRemoteDataSource,
    required NetworkInfo networkInfo,
  }) : _authDatasource = authDatasource,
       _authRemoteDataSource = authRemoteDataSource,
       _networkInfo = networkInfo;

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
  Future<Either<Failure, bool>> register(AuthEntity user) async {
    if (await _networkInfo.isConnected) {
      try {
        //remote ma ja
        final apiModel = AuthApiModel.fromEntity(user);
        await _authRemoteDataSource.register(apiModel);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data is Map
                ? e.response?.data['message']
                : e.response?.data?.toString() ?? 'Registration failed',

            statusCode: e.response?.statusCode,
          ),
        );
      }
    } else {
      try {
        // Check if user already exists
        final existingUser = _authDatasource.getUserByEmail(user.email);
        if (existingUser != null) {
          return Left(LocalDatabaseFailure(message: "Email already exists"));
        }
        final model = AuthHiveModel.fromEntity(user);
        final result = await _authDatasource.register(model);
        if (!result) {
          return Left(LocalDatabaseFailure(message: "Failed to register user"));
        }
        return Right(true);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
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
