import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jerseypasal/core/error/failures.dart';
import 'package:jerseypasal/features/auth/domain/usecases/login_usecase.dart';
import 'package:jerseypasal/features/auth/domain/usecases/register_usecase.dart';
import 'package:jerseypasal/features/auth/domain/usecases/logout_usecase.dart';
import 'package:jerseypasal/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:jerseypasal/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:jerseypasal/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:jerseypasal/features/auth/presentation/state/auth_state.dart';

class MockLoginUsecase extends Mock implements LoginUsecase {}
class MockRegisterUsecase extends Mock implements RegisterUsecase {}
class MockLogoutUsecase extends Mock implements LogoutUsecase {}
class MockGetCurrentUserUsecase extends Mock implements GetCurrentUserUsecase {}
class MockResetPasswordUsecase extends Mock implements ResetPasswordUsecase {}
class MockBuildContext extends Mock implements BuildContext {}

const tEmail = 'test@example.com';
const tPassword = 'password123';

void main() {
  setUpAll(() {
    registerFallbackValue(LoginUsecaseParams(email: '', password: ''));
    registerFallbackValue(RegisterUsecaseParams(email: '', password: ''));
    registerFallbackValue(ResetPasswordUsecaseParams(email: '', newPassword: ''));
  });

  test('5. register failure sets status to error with message', () async {
    final mockRegister = MockRegisterUsecase();
    when(() => mockRegister.call(any()))
        .thenAnswer((_) async => Left(ApiFailure(message: 'Email already exists')));

    final container = ProviderContainer(overrides: [
      loginUsecaseProvider.overrideWithValue(MockLoginUsecase()),
      registerUsecaseProvider.overrideWithValue(mockRegister),
      logoutUsecaseProvider.overrideWithValue(MockLogoutUsecase()),
      getCurrentUserUsecaseProvider.overrideWithValue(MockGetCurrentUserUsecase()),
      resetPasswordUsecaseProvider.overrideWithValue(MockResetPasswordUsecase()),
    ]);

    await container.read(authViewModelProvider.notifier).register(
      context: MockBuildContext(),
      email: tEmail,
      password: tPassword,
    );

    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.error);
    expect(state.errorMessage, 'Email already exists');
  });
}
