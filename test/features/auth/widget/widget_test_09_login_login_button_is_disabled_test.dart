import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jerseypasal/core/error/failures.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jerseypasal/features/auth/domain/entities/auth_entity.dart';
import 'package:jerseypasal/features/auth/domain/usecases/login_usecase.dart';
import 'package:jerseypasal/features/auth/domain/usecases/register_usecase.dart';
import 'package:jerseypasal/features/auth/domain/usecases/logout_usecase.dart';
import 'package:jerseypasal/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:jerseypasal/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:jerseypasal/features/auth/presentation/pages/Jersey_Login_Screen.dart';

class MockLoginUsecase extends Mock implements LoginUsecase {}
class MockRegisterUsecase extends Mock implements RegisterUsecase {}
class MockLogoutUsecase extends Mock implements LogoutUsecase {}
class MockGetCurrentUserUsecase extends Mock implements GetCurrentUserUsecase {}
class MockResetPasswordUsecase extends Mock implements ResetPasswordUsecase {}

const tEmail = 'test@example.com';
const tPassword = 'password123';
const tAuthEntity = AuthEntity(email: tEmail);

void main() {
  late MockLoginUsecase mockLogin;

  setUpAll(() {
    registerFallbackValue(LoginUsecaseParams(email: '', password: ''));
    registerFallbackValue(RegisterUsecaseParams(email: '', password: ''));
    registerFallbackValue(ResetPasswordUsecaseParams(email: '', newPassword: ''));
  });

  setUp(() {
    mockLogin = MockLoginUsecase();
  });

  testWidgets('9. login button is disabled when loading', (tester) async {
    // Completer keeps login pending — button stays disabled
    final completer = Completer<Either<Failure, AuthEntity>>();
    when(() => mockLogin.call(any())).thenAnswer((_) async => completer.future);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          loginUsecaseProvider.overrideWithValue(mockLogin),
          registerUsecaseProvider.overrideWithValue(MockRegisterUsecase()),
          logoutUsecaseProvider.overrideWithValue(MockLogoutUsecase()),
          getCurrentUserUsecaseProvider.overrideWithValue(MockGetCurrentUserUsecase()),
          resetPasswordUsecaseProvider.overrideWithValue(MockResetPasswordUsecase()),
        ],
        child: const MaterialApp(home: JerseyLoginScreen()),
      ),
    );

    await tester.enterText(
        find.widgetWithIcon(TextFormField, Icons.email), tEmail);
    await tester.enterText(
        find.widgetWithIcon(TextFormField, Icons.lock), tPassword);
    await tester.tap(find.text('Login'));
    await tester.pump(); // loading state kicks in

    final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(btn.onPressed, isNull); // disabled during loading

    // Clean up — resolve so no pending timers
    completer.complete(const Right(tAuthEntity));
    await tester.pump();
  });
}