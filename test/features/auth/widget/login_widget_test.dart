import 'dart:async';
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
final tAuthEntity = AuthEntity(email: tEmail);

// ─── Builder ─────────────────────────────────────────────────────────────────
// FIX: Use onGenerateRoute to intercept navigation away from the login screen.
//      When login succeeds the app tries to push the home screen which calls
//      Hive.box() in initState — Hive is not open in tests so it crashes.
//      Returning a blank scaffold for any unknown route prevents this.

Widget buildLogin({MockLoginUsecase? mockLogin}) => ProviderScope(
  overrides: [
    loginUsecaseProvider.overrideWithValue(mockLogin ?? MockLoginUsecase()),
    registerUsecaseProvider.overrideWithValue(MockRegisterUsecase()),
    logoutUsecaseProvider.overrideWithValue(MockLogoutUsecase()),
    getCurrentUserUsecaseProvider.overrideWithValue(
      MockGetCurrentUserUsecase(),
    ),
    resetPasswordUsecaseProvider.overrideWithValue(MockResetPasswordUsecase()),
  ],
  child: MediaQuery(
    data: const MediaQueryData(size: Size(800, 1200)),
    child: MaterialApp(
      home: const JerseyLoginScreen(),
      // Intercept any navigation (e.g. to HomeScreen after login)
      // and show a blank page so Hive is never touched.
      onGenerateRoute: (_) =>
          MaterialPageRoute(builder: (_) => const Scaffold(body: SizedBox())),
    ),
  ),
);

// ─── Helper: scroll into view then tap ───────────────────────────────────────

Future<void> scrollAndTap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

// ─── Helper: find text inside RichText spans ─────────────────────────────────
// FIX: find.text / find.textContaining do not search inside RichText by default.
//      This predicate walks the TextSpan tree to find matching text.

Finder findRichText(String substring) => find.byWidgetPredicate((widget) {
  if (widget is RichText) {
    final text = widget.text.toPlainText();
    return text.contains(substring);
  }
  return false;
});

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    registerFallbackValue(LoginUsecaseParams(email: '', password: ''));
    registerFallbackValue(
      ResetPasswordUsecaseParams(email: '', newPassword: ''),
    );
  });

  group('Login Screen — Widget Tests', () {
    // TC-LOGIN-W-01
    testWidgets(
      'TC-LOGIN-W-01: renders email field, password field and Sign In button',
      (tester) async {
        await tester.pumpWidget(buildLogin());
        await tester.pumpAndSettle();

        expect(find.byType(TextFormField), findsNWidgets(2));
        expect(find.text('Sign In'), findsOneWidget);
        expect(find.text('Sign in to Jerseyपसल'), findsOneWidget);
      },
    );

    // TC-LOGIN-W-02
    testWidgets('TC-LOGIN-W-02: shows error when email is empty on submit', (
      tester,
    ) async {
      await tester.pumpWidget(buildLogin());
      await tester.pumpAndSettle();

      await scrollAndTap(tester, find.text('Sign In'));

      expect(find.text('Email cannot be empty'), findsOneWidget);
    });

    // TC-LOGIN-W-03
    testWidgets('TC-LOGIN-W-03: shows error when password is empty on submit', (
      tester,
    ) async {
      await tester.pumpWidget(buildLogin());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'you@example.com'),
        tEmail,
      );
      await scrollAndTap(tester, find.text('Sign In'));

      expect(find.text('Password cannot be empty'), findsOneWidget);
    });

    // TC-LOGIN-W-04
    testWidgets('TC-LOGIN-W-04: shows error for invalid email format', (
      tester,
    ) async {
      await tester.pumpWidget(buildLogin());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'you@example.com'),
        'not-an-email',
      );
      await scrollAndTap(tester, find.text('Sign In'));

      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    // TC-LOGIN-W-05
    testWidgets(
      'TC-LOGIN-W-05: shows error when password is shorter than 6 chars',
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
        await scrollAndTap(tester, find.text('Sign In'));

        expect(
          find.text('Password must be at least 6 characters'),
          findsOneWidget,
        );
      },
    );

    // TC-LOGIN-W-06
    // FIX: RichText spans not found by find.text/textContaining.
    //      Use findRichText() which searches toPlainText() of the widget.
    testWidgets('TC-LOGIN-W-06: shows Create one link on login screen', (
      tester,
    ) async {
      await tester.pumpWidget(buildLogin());
      await tester.pumpAndSettle();

      expect(findRichText("Don't have an account?"), findsOneWidget);
      expect(findRichText('Create one'), findsOneWidget);
    });
  });
}
