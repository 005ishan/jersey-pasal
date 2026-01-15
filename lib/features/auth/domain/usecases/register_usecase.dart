import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerseypasal/core/error/failures.dart';
import 'package:jerseypasal/core/usecases/app_usecase.dart';
import 'package:jerseypasal/features/auth/data/repositories/auth_repository.dart';
import 'package:jerseypasal/features/auth/domain/entities/auth_entity.dart';
import 'package:jerseypasal/features/auth/domain/repositories/auth_repository.dart';

class RegisterUsecaseParams extends Equatable {
  final String email;
  final String? password;

  RegisterUsecaseParams({
    required this.email,
    required this.password,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [email, password];
}

// provider
final registerUsecaseProvider = Provider<RegisterUsecase>(
  (ref) => RegisterUsecase(authRepository: ref.read(authRepositoryProvider)),
);

class RegisterUsecase
    implements UsecaseWithParams<bool, RegisterUsecaseParams> {
  final IAuthRepository _authRepository;
  RegisterUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParams params) {
    final entity = AuthEntity(
      email: params.email,
      password: params.password,
    );
    return _authRepository.register(entity);
  }
}
