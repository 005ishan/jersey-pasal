import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerseypasal/core/error/failures.dart';
import 'package:jerseypasal/core/usecases/app_usecase.dart';
import 'package:jerseypasal/features/auth/data/repositories/auth_repository.dart';
import 'package:jerseypasal/features/auth/domain/repositories/auth_repository.dart';

//provider
final logoutUsecaseProvider = Provider<LogoutUsecase>(
  (ref) => LogoutUsecase(authRepository: ref.read(authRepositoryProvider)),
);

class LogoutUsecase implements UsecaseWithoutParams<bool> {
  final IAuthRepository _authRepository;

  LogoutUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call([void params]) {
    return _authRepository.logout();
  }
}
