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

  testWidgets('7. shows loading indicator while login is in progress',
      (tester) async {
    // Use a Completer so the future never resolves during this test —
    // the login stays in "loading" state the whole time.
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
    await tester.pump(); // trigger loading state

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Resolve the completer so the test ends cleanly (no pending timers)
    completer.complete(const Right(tAuthEntity));
    await tester.pump();
  });
}