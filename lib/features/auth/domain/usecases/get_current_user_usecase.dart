import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerseypasal/core/error/failures.dart';
import 'package:jerseypasal/core/usecases/app_usecase.dart';
import 'package:jerseypasal/features/auth/data/repositories/auth_repository.dart';
import 'package:jerseypasal/features/auth/domain/entities/auth_entity.dart';
import 'package:jerseypasal/features/auth/domain/repositories/auth_repository.dart';

//provider
final getCurrentUserUsecaseProvider = Provider<GetCurrentUserUsecase>(
  (ref) =>
      GetCurrentUserUsecase(authRepository: ref.read(authRepositoryProvider)),
);

class GetCurrentUserUsecase implements UsecaseWithoutParams<AuthEntity> {
  final IAuthRepository _authRepository;

  GetCurrentUserUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call([void params]) {
    return _authRepository.getCurrentUser();
  }
}
