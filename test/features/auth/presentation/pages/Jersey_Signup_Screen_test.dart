import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerseypasal/features/auth/presentation/pages/Jersey_Signup_Screen.dart';
import 'package:jerseypasal/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:jerseypasal/features/auth/presentation/state/auth_state.dart';

class MockAuthViewModel extends AuthViewModel {
  @override
  AuthState build() {
    return AuthState(status: AuthStatus.initial);
  }

  @override
  Future<void> register({
    required BuildContext context,
    required String email,
    required String password,
  }) async {}
}

void main() {
  testWidgets(
    'Can type in email/password, check terms, and tap sign up button',
    (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          authViewModelProvider.overrideWith(() => MockAuthViewModel()),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: JerseySignupScreen()),
        ),
      );

      // Find fields and button
      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);
      final confirmPasswordField = find.byType(TextFormField).at(2);
      final checkbox = find.byType(CheckboxListTile);
      final signUpButton = find.byType(ElevatedButton);

      // Type into the fields
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, '123456');
      await tester.enterText(confirmPasswordField, '123456');

      // Tap the checkbox
      await tester.tap(checkbox);

      // Verify the text and checkbox
      expect(find.text('test@example.com'), findsOneWidget);
      expect(
        find.text('123456'),
        findsNWidgets(2),
      ); // password + confirm password

      // Tap the Sign Up button
      await tester.tap(signUpButton);
      await tester.pump();

      // Verify button exists
      expect(signUpButton, findsOneWidget);
    },
  );
}
