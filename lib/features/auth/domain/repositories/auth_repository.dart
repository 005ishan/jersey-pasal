import 'package:dartz/dartz.dart';
import 'package:jerseypasal/core/error/failures.dart';
import '../entities/auth_entity.dart';

abstract class IAuthRepository {
  Future<Either<Failure, AuthEntity>> login(String email, String password);
  Future<Either<Failure, bool>> register(AuthEntity entity);
  Future<Either<Failure, bool>> logout();
  Future<Either<Failure, AuthEntity>> getCurrentUser();
  Future<Either<Failure, bool>> resetPassword({
    required String email,
    required String newPassword,
  });
}
