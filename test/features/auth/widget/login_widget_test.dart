import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:jerseypasal/features/auth/domain/entities/auth_entity.dart';
import 'package:jerseypasal/features/auth/domain/usecases/login_usecase.dart';
import 'package:jerseypasal/features/auth/domain/usecases/register_usecase.dart';
import 'package:jerseypasal/features/auth/domain/usecases/logout_usecase.dart';
import 'package:jerseypasal/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:jerseypasal/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:jerseypasal/features/auth/presentation/pages/Jersey_Login_Screen.dart';

// ─── Mocks ───────────────────────────────────────────────────────────────────

class MockLoginUsecase extends Mock implements LoginUsecase {}
class MockRegisterUsecase extends Mock implements RegisterUsecase {}
class MockLogoutUsecase extends Mock implements LogoutUsecase {}
class MockGetCurrentUserUsecase extends Mock implements GetCurrentUserUsecase {}
class MockResetPasswordUsecase extends Mock implements ResetPasswordUsecase {}

// ─── Constants ───────────────────────────────────────────────────────────────

const tEmail = 'test@example.com';
const tPassword = 'password123';
// FIX: Removed const — dartz Right() does not support const constructor
final tAuthEntity = AuthEntity(email: tEmail);

// ─── Builder ─────────────────────────────────────────────────────────────────

Widget buildLogin({MockLoginUsecase? mockLogin}) => ProviderScope(
      overrides: [
        loginUsecaseProvider.overrideWithValue(mockLogin ?? MockLoginUsecase()),
        registerUsecaseProvider.overrideWithValue(MockRegisterUsecase()),
        logoutUsecaseProvider.overrideWithValue(MockLogoutUsecase()),
        getCurrentUserUsecaseProvider.overrideWithValue(MockGetCurrentUserUsecase()),
        resetPasswordUsecaseProvider.overrideWithValue(MockResetPasswordUsecase()),
      ],
      child: const MaterialApp(home: JerseyLoginScreen()),
    );

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    registerFallbackValue(LoginUsecaseParams(email: '', password: ''));
    registerFallbackValue(ResetPasswordUsecaseParams(email: '', newPassword: ''));
  });

  group('Login Screen — Widget Tests', () {
    // TC-LOGIN-W-01
    // Button is 'Sign In', subtitle is 'Sign in to Jerseyपसल'
    testWidgets('TC-LOGIN-W-01: renders email field, password field and Sign In button',
        (tester) async {
      await tester.pumpWidget(buildLogin());
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Sign in to Jerseyपसल'), findsOneWidget);
    });

    // TC-LOGIN-W-02
    testWidgets('TC-LOGIN-W-02: shows error when email is empty on submit',
        (tester) async {
      await tester.pumpWidget(buildLogin());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Email cannot be empty'), findsOneWidget);
    });

    // TC-LOGIN-W-03
    // Fill email, leave password empty — expect password error
    testWidgets('TC-LOGIN-W-03: shows error when password is empty on submit',
        (tester) async {
      await tester.pumpWidget(buildLogin());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'you@example.com'),
        tEmail,
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Password cannot be empty'), findsOneWidget);
    });

    // TC-LOGIN-W-04
    testWidgets('TC-LOGIN-W-04: shows error for invalid email format',
        (tester) async {
      await tester.pumpWidget(buildLogin());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'you@example.com'),
        'not-an-email',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    // TC-LOGIN-W-05
    testWidgets('TC-LOGIN-W-05: shows error when password is shorter than 6 chars',
        (tester) async {
      await tester.pumpWidget(buildLogin());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'you@example.com'),
        tEmail,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '••••••••'),
        'abc',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    // TC-LOGIN-W-06
    // FIX: Right(tAuthEntity) not const Right(tAuthEntity)
    testWidgets('TC-LOGIN-W-06: calls login usecase when form is valid',
        (tester) async {
      final mockLogin = MockLoginUsecase();
      when(() => mockLogin(any()))
          .thenAnswer((_) async => Right(tAuthEntity));

      await tester.pumpWidget(buildLogin(mockLogin: mockLogin));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'you@example.com'),
        tEmail,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '••••••••'),
        tPassword,
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      verify(() => mockLogin(any())).called(1);
    });

    // TC-LOGIN-W-07
    // Never-completing future keeps loading state active for one frame
    testWidgets('TC-LOGIN-W-07: shows loading indicator while login is in progress',
        (tester) async {
      final mockLogin = MockLoginUsecase();
      when(() => mockLogin(any())).thenAnswer(
        (_) async => Future.delayed(
          const Duration(seconds: 60),
          () => Right(tAuthEntity),
        ),
      );

      await tester.pumpWidget(buildLogin(mockLogin: mockLogin));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'you@example.com'),
        tEmail,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '••••••••'),
        tPassword,
      );
      await tester.tap(find.text('Sign In'));
      await tester.pump(); // one frame — loading state visible

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // TC-LOGIN-W-08
    // Login screen shows 'Create one' link, not 'Sign Up'
    testWidgets('TC-LOGIN-W-08: shows Create one link on login screen',
        (tester) async {
      await tester.pumpWidget(buildLogin());
      await tester.pumpAndSettle();

      expect(find.text("Don't have an account?  "), findsOneWidget);
      expect(find.text('Create one'), findsOneWidget);
    });

    // TC-LOGIN-W-09
    // Button onPressed becomes null (disabled) while loading
    testWidgets('TC-LOGIN-W-09: login button is disabled when loading',
        (tester) async {
      final mockLogin = MockLoginUsecase();
      when(() => mockLogin(any())).thenAnswer(
        (_) async => Future.delayed(
          const Duration(seconds: 60),
          () => Right(tAuthEntity),
        ),
      );

      await tester.pumpWidget(buildLogin(mockLogin: mockLogin));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'you@example.com'),
        tEmail,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '••••••••'),
        tPassword,
      );
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton).first,
      );
      expect(button.onPressed, isNull);
    });

    // TC-LOGIN-W-10
    // Valid input — no validation errors should appear
    testWidgets('TC-LOGIN-W-10: no validation errors shown on valid email and password',
        (tester) async {
      final mockLogin = MockLoginUsecase();
      when(() => mockLogin(any()))
          .thenAnswer((_) async => Right(tAuthEntity));

      await tester.pumpWidget(buildLogin(mockLogin: mockLogin));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'you@example.com'),
        tEmail,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '••••••••'),
        tPassword,
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Email cannot be empty'), findsNothing);
      expect(find.text('Password cannot be empty'), findsNothing);
      expect(find.text('Enter a valid email'), findsNothing);
    });
  });
}