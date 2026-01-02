import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerseypasal/core/error/failures.dart';
import 'package:jerseypasal/core/usecases/app_usecase.dart';
import 'package:jerseypasal/features/auth/data/repositories/auth_repository.dart';
import 'package:jerseypasal/features/auth/domain/entities/auth_entity.dart';
import 'package:jerseypasal/features/auth/domain/repositories/auth_repository.dart';

class LoginUsecaseParams extends Equatable {
  final String email;
  final String password;

  LoginUsecaseParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

// provider
final loginUsecaseProvider = Provider<LoginUsecase>(
  (ref) => LoginUsecase(authRepository: ref.read(authRepositoryProvider)),
);

class LoginUsecase
    implements UsecaseWithParams<AuthEntity, LoginUsecaseParams> {
  final IAuthRepository _authRepository;

  LoginUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(LoginUsecaseParams params) {
    return _authRepository.login(params.email, params.password);
  }
}
