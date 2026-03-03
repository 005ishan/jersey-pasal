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
import 'package:jerseypasal/features/auth/presentation/pages/Jersey_Signup_Screen.dart';

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

Widget buildSignup({MockRegisterUsecase? mockRegister}) => ProviderScope(
      overrides: [
        loginUsecaseProvider.overrideWithValue(MockLoginUsecase()),
        registerUsecaseProvider
            .overrideWithValue(mockRegister ?? MockRegisterUsecase()),
        logoutUsecaseProvider.overrideWithValue(MockLogoutUsecase()),
        getCurrentUserUsecaseProvider
            .overrideWithValue(MockGetCurrentUserUsecase()),
        resetPasswordUsecaseProvider
            .overrideWithValue(MockResetPasswordUsecase()),
      ],
      child: const MaterialApp(home: JerseySignupScreen()),
    );

// ─── Helpers ─────────────────────────────────────────────────────────────────

/// Fills all 3 form fields with valid data
Future<void> fillValidForm(WidgetTester tester) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'you@example.com'),
    tEmail,
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, '••••••••').first,
    tPassword,
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, '••••••••').last,
    tPassword,
  );
}

/// Taps the custom terms row (AnimatedContainer, not CheckboxListTile)
Future<void> acceptTerms(WidgetTester tester) async {
  await tester.tap(
    find.text('I agree to the Terms & Conditions and Privacy Policy'),
  );
  await tester.pumpAndSettle();
}

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    registerFallbackValue(RegisterUsecaseParams(email: '', password: ''));
    registerFallbackValue(LoginUsecaseParams(email: '', password: ''));
    registerFallbackValue(ResetPasswordUsecaseParams(email: '', newPassword: ''));
  });

  group('Signup Screen — Widget Tests', () {
    // TC-SIGNUP-W-01
    // Button is 'Create Account' not 'Sign Up'. 3 TextFormFields.
    testWidgets(
        'TC-SIGNUP-W-01: renders email, password, confirm password and Create Account button',
        (tester) async {
      await tester.pumpWidget(buildSignup());
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Join Jerseyपसल today'), findsOneWidget);
    });

    // TC-SIGNUP-W-02
    // Tap 'Create Account' with no input — email error shows
    testWidgets('TC-SIGNUP-W-02: shows error when email is empty on submit',
        (tester) async {
      await tester.pumpWidget(buildSignup());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Email cannot be empty'), findsOneWidget);
    });

    // TC-SIGNUP-W-03
    testWidgets('TC-SIGNUP-W-03: shows error for invalid email format on signup',
        (tester) async {
      await tester.pumpWidget(buildSignup());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'you@example.com'),
        'not-valid',
      );
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    // TC-SIGNUP-W-04
    // .first targets password field, .last targets confirm field
    testWidgets(
        'TC-SIGNUP-W-04: shows error when password is shorter than 6 chars on signup',
        (tester) async {
      await tester.pumpWidget(buildSignup());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'you@example.com'),
        tEmail,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '••••••••').first,
        'abc',
      );
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    // TC-SIGNUP-W-05
    testWidgets('TC-SIGNUP-W-05: shows error when passwords do not match',
        (tester) async {
      await tester.pumpWidget(buildSignup());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'you@example.com'),
        tEmail,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '••••••••').first,
        tPassword,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '••••••••').last,
        'differentpassword',
      );
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    // TC-SIGNUP-W-06
    // Terms is NOT a CheckboxListTile — it's a custom GestureDetector + Row.
    // Submitting without ticking terms shows a SnackBar.
    testWidgets('TC-SIGNUP-W-06: shows snackbar when terms not checked',
        (tester) async {
      await tester.pumpWidget(buildSignup());
      await tester.pumpAndSettle();

      await fillValidForm(tester);
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(
        find.text('You must agree to Terms & Privacy Policy'),
        findsOneWidget,
      );
    });

    // TC-SIGNUP-W-07
    // Terms row uses AnimatedContainer, found by its text label
    testWidgets('TC-SIGNUP-W-07: terms and conditions row is rendered',
        (tester) async {
      await tester.pumpWidget(buildSignup());
      await tester.pumpAndSettle();

      expect(
        find.text('I agree to the Terms & Conditions and Privacy Policy'),
        findsOneWidget,
      );
    });

    // TC-SIGNUP-W-08
    // Tap terms text to toggle, then submit — register usecase called once
    // FIX: Right(tAuthEntity) not const Right(tAuthEntity)
    testWidgets(
        'TC-SIGNUP-W-08: calls register usecase when form is valid and terms accepted',
        (tester) async {
      final mockRegister = MockRegisterUsecase();
      when(() => mockRegister(any()))
          .thenAnswer((_) async => Right(tAuthEntity));

      await tester.pumpWidget(buildSignup(mockRegister: mockRegister));
      await tester.pumpAndSettle();

      await fillValidForm(tester);
      await acceptTerms(tester);

      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      verify(() => mockRegister(any())).called(1);
    });

    // TC-SIGNUP-W-09
    // Signup screen shows 'Sign in' link (note: double space before 'Sign in')
    testWidgets('TC-SIGNUP-W-09: shows login redirect link on signup screen',
        (tester) async {
      await tester.pumpWidget(buildSignup());
      await tester.pumpAndSettle();

      expect(find.text('Already have an account?  '), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
    });

    // TC-SIGNUP-W-10
    // Tap terms + submit with never-resolving mock → loading indicator shows
    testWidgets('TC-SIGNUP-W-10: shows loading indicator while registering',
        (tester) async {
      final mockRegister = MockRegisterUsecase();
      when(() => mockRegister(any())).thenAnswer(
        (_) async => Future.delayed(
          const Duration(seconds: 60),
          () => Right(tAuthEntity),
        ),
      );

      await tester.pumpWidget(buildSignup(mockRegister: mockRegister));
      await tester.pumpAndSettle();

      await fillValidForm(tester);
      await acceptTerms(tester);

      await tester.tap(find.text('Create Account'));
      await tester.pump(); // one frame — loading state visible

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}