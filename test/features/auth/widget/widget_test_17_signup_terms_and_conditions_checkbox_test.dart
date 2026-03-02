import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jerseypasal/core/error/failures.dart';
import 'package:jerseypasal/features/auth/domain/entities/auth_entity.dart';
import 'package:jerseypasal/features/auth/domain/usecases/login_usecase.dart';
import 'package:jerseypasal/features/auth/domain/usecases/register_usecase.dart';
import 'package:jerseypasal/features/auth/domain/usecases/logout_usecase.dart';
import 'package:jerseypasal/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:jerseypasal/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:jerseypasal/features/auth/presentation/pages/Jersey_Signup_Screen.dart';

class MockLoginUsecase extends Mock implements LoginUsecase {}
class MockRegisterUsecase extends Mock implements RegisterUsecase {}
class MockLogoutUsecase extends Mock implements LogoutUsecase {}
class MockGetCurrentUserUsecase extends Mock implements GetCurrentUserUsecase {}
class MockResetPasswordUsecase extends Mock implements ResetPasswordUsecase {}

const tEmail = 'test@example.com';
const tPassword = 'password123';
const tAuthEntity = AuthEntity(email: tEmail);

void main() {
  late MockRegisterUsecase mockRegister;

  setUpAll(() {
    registerFallbackValue(LoginUsecaseParams(email: '', password: ''));
    registerFallbackValue(RegisterUsecaseParams(email: '', password: ''));
    registerFallbackValue(ResetPasswordUsecaseParams(email: '', newPassword: ''));
  });

  setUp(() {
    mockRegister = MockRegisterUsecase();
  });

  Widget buildSignup() => ProviderScope(
    overrides: [
      loginUsecaseProvider.overrideWithValue(MockLoginUsecase()),
      registerUsecaseProvider.overrideWithValue(mockRegister),
      logoutUsecaseProvider.overrideWithValue(MockLogoutUsecase()),
      getCurrentUserUsecaseProvider.overrideWithValue(MockGetCurrentUserUsecase()),
      resetPasswordUsecaseProvider.overrideWithValue(MockResetPasswordUsecase()),
    ],
    child: const MaterialApp(home: JerseySignupScreen()),
  );

  testWidgets('17. terms and conditions checkbox is rendered', (tester) async {
    await tester.pumpWidget(buildSignup());
    expect(find.byType(CheckboxListTile), findsOneWidget);
    expect(find.text('I agree to the Terms & Conditions and Privacy Policy'), findsOneWidget);
  });
}
