import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerseypasal/core/error/failures.dart';
import 'package:jerseypasal/core/usecases/app_usecase.dart';
import 'package:jerseypasal/features/auth/data/repositories/auth_repository.dart';
import 'package:jerseypasal/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordUsecaseParams extends Equatable {
  final String email;
  final String newPassword;

  ResetPasswordUsecaseParams({required this.email, required this.newPassword});

  @override
  List<Object?> get props => [email, newPassword];
}

//provider
final resetPasswordUsecaseProvider = Provider<ResetPasswordUsecase>(
  (ref) =>
      ResetPasswordUsecase(authRepository: ref.read(authRepositoryProvider)),
);

class ResetPasswordUsecase
    implements UsecaseWithParams<bool, ResetPasswordUsecaseParams> {
  final IAuthRepository _authRepository;

  ResetPasswordUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(ResetPasswordUsecaseParams params) {
    return _authRepository.resetPassword(
      email: params.email,
      newPassword: params.newPassword,
    );
  }
}
