import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerseypasal/features/auth/domain/usecases/login_usecase.dart';
import 'package:jerseypasal/features/auth/domain/usecases/register_usecase.dart';
import 'package:jerseypasal/features/auth/domain/usecases/logout_usecase.dart';
import 'package:jerseypasal/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:jerseypasal/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:jerseypasal/features/auth/presentation/pages/Jersey_Login_Screen.dart';
import 'package:jerseypasal/features/auth/presentation/pages/Jersey_Signup_Screen.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUsecase extends Mock implements LoginUsecase {}
class MockRegisterUsecase extends Mock implements RegisterUsecase {}
class MockLogoutUsecase extends Mock implements LogoutUsecase {}
class MockGetCurrentUserUsecase extends Mock implements GetCurrentUserUsecase {}
class MockResetPasswordUsecase extends Mock implements ResetPasswordUsecase {}

Widget buildLogin({
  MockLoginUsecase? mockLogin,
  MockRegisterUsecase? mockRegister,
}) =>
    ProviderScope(
      overrides: [
        loginUsecaseProvider.overrideWithValue(mockLogin ?? MockLoginUsecase()),
        registerUsecaseProvider.overrideWithValue(mockRegister ?? MockRegisterUsecase()),
        logoutUsecaseProvider.overrideWithValue(MockLogoutUsecase()),
        getCurrentUserUsecaseProvider.overrideWithValue(MockGetCurrentUserUsecase()),
        resetPasswordUsecaseProvider.overrideWithValue(MockResetPasswordUsecase()),
      ],
      child: const MaterialApp(home: JerseyLoginScreen()),
    );

Widget buildSignup({
  MockLoginUsecase? mockLogin,
  MockRegisterUsecase? mockRegister,
}) =>
    ProviderScope(
      overrides: [
        loginUsecaseProvider.overrideWithValue(mockLogin ?? MockLoginUsecase()),
        registerUsecaseProvider.overrideWithValue(mockRegister ?? MockRegisterUsecase()),
        logoutUsecaseProvider.overrideWithValue(MockLogoutUsecase()),
        getCurrentUserUsecaseProvider.overrideWithValue(MockGetCurrentUserUsecase()),
        resetPasswordUsecaseProvider.overrideWithValue(MockResetPasswordUsecase()),
      ],
      child: const MaterialApp(home: JerseySignupScreen()),
    );