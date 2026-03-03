import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jerseypasal/core/error/failures.dart';
import 'package:mocktail/mocktail.dart';
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

// ─── Builder ─────────────────────────────────────────────────────────────────
// FIX: onGenerateRoute intercepts navigation away from signup (e.g. to login
//      or home) so Hive is never accessed during tests.

Widget buildSignup({MockRegisterUsecase? mockRegister}) => ProviderScope(
      overrides: [
        loginUsecaseProvider.overrideWithValue(MockLoginUsecase()),
        registerUsecaseProvider
            .overrideWithValue(mockRegister ?? MockRegisterUsecase()),
        logoutUsecaseProvider.overrideWithValue(MockLogoutUsecase()),
        getCurrentUserUsecaseProvider.overrideWithValue(MockGetCurrentUserUsecase()),
        resetPasswordUsecaseProvider.overrideWithValue(MockResetPasswordUsecase()),
      ],
      child: MediaQuery(
        data: const MediaQueryData(size: Size(800, 1400)),
        child: MaterialApp(
          home: const JerseySignupScreen(),
          onGenerateRoute: (_) => MaterialPageRoute(
            builder: (_) => const Scaffold(body: SizedBox()),
          ),
        ),
      ),
    );

// ─── Helpers ─────────────────────────────────────────────────────────────────

Future<void> scrollAndTap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

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

Future<void> acceptTerms(WidgetTester tester) async {
  await tester.ensureVisible(
    find.text('I agree to the Terms & Conditions and Privacy Policy'),
  );
  await tester.pumpAndSettle();
  await tester.tap(
    find.text('I agree to the Terms & Conditions and Privacy Policy'),
  );
  await tester.pumpAndSettle();
}

// FIX: RichText spans not found by find.text/textContaining.
//      Walk toPlainText() of the RichText widget to match substrings.
Finder findRichText(String substring) => find.byWidgetPredicate(
      (widget) {
        if (widget is RichText) {
          return widget.text.toPlainText().contains(substring);
        }
        return false;
      },
    );

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    registerFallbackValue(RegisterUsecaseParams(email: '', password: ''));
    registerFallbackValue(LoginUsecaseParams(email: '', password: ''));
    registerFallbackValue(ResetPasswordUsecaseParams(email: '', newPassword: ''));
  });

  group('Signup Screen — Widget Tests', () {
    // TC-SIGNUP-W-01
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
    testWidgets('TC-SIGNUP-W-02: shows error when email is empty on submit',
        (tester) async {
      await tester.pumpWidget(buildSignup());
      await tester.pumpAndSettle();

      await scrollAndTap(tester, find.text('Create Account'));

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
      await scrollAndTap(tester, find.text('Create Account'));

      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    // TC-SIGNUP-W-04
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
      await scrollAndTap(tester, find.text('Create Account'));

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
      await scrollAndTap(tester, find.text('Create Account'));

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    // TC-SIGNUP-W-06
    testWidgets('TC-SIGNUP-W-06: shows snackbar when terms not checked',
        (tester) async {
      await tester.pumpWidget(buildSignup());
      await tester.pumpAndSettle();

      await fillValidForm(tester);
      await scrollAndTap(tester, find.text('Create Account'));

      expect(
        find.text('You must agree to Terms & Privacy Policy'),
        findsOneWidget,
      );
    });

    // TC-SIGNUP-W-07
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
    testWidgets(
        'TC-SIGNUP-W-08: calls register usecase when form is valid and terms accepted',
        (tester) async {
      final mockRegister = MockRegisterUsecase();
      when(() => mockRegister(any()))
          .thenAnswer((_) async => const Right(true));

      await tester.pumpWidget(buildSignup(mockRegister: mockRegister));
      await tester.pumpAndSettle();

      await fillValidForm(tester);
      await acceptTerms(tester);
      await scrollAndTap(tester, find.text('Create Account'));

      verify(() => mockRegister(any())).called(1);
    });

    // TC-SIGNUP-W-09
    // FIX: RichText not found by find.textContaining — use findRichText().
    testWidgets('TC-SIGNUP-W-09: shows login redirect link on signup screen',
        (tester) async {
      await tester.pumpWidget(buildSignup());
      await tester.pumpAndSettle();

      expect(findRichText('Already have an account?'), findsOneWidget);
      expect(findRichText('Sign in'), findsOneWidget);
    });

    // TC-SIGNUP-W-10
    // FIX: Completer instead of Future.delayed — no pending timer left after test.
    testWidgets('TC-SIGNUP-W-10: shows loading indicator while registering',
        (tester) async {
      final mockRegister = MockRegisterUsecase();
      final completer = Completer<Either<Failure, bool>>();
      when(() => mockRegister(any())).thenAnswer((_) async => completer.future);

      await tester.pumpWidget(buildSignup(mockRegister: mockRegister));
      await tester.pumpAndSettle();

      await fillValidForm(tester);
      await acceptTerms(tester);

      await tester.ensureVisible(find.text('Create Account'));
      await tester.pump();
      await tester.tap(find.text('Create Account'));
      await tester.pump(); // single frame — loading visible

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete to clean up async work
      completer.complete(const Right(true));
      await tester.pumpAndSettle();
    });
  });
}