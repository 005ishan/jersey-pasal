import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerseypasal/features/auth/presentation/pages/Jersey_Login_Screen.dart';
import 'package:jerseypasal/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:jerseypasal/features/auth/presentation/state/auth_state.dart';

class MockAuthViewModel extends AuthViewModel {
  @override
  AuthState build() {
    return AuthState(status: AuthStatus.initial);
  }

  @override
  Future<void> login({
    required BuildContext context,
    required String email,
    required String password,
  }) async {}
}

void main() {
  testWidgets('Can type in email/password and tap login button', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        authViewModelProvider.overrideWith(() => MockAuthViewModel()),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: JerseyLoginScreen()),
      ),
    );

    // Find email and password fields
    final emailField = find.byType(TextFormField).at(0);
    final passwordField = find.byType(TextFormField).at(1);
    final loginButton = find.byType(ElevatedButton);

    // Type into the fields
    await tester.enterText(emailField, 'test@example.com');
    await tester.enterText(passwordField, '123456');

    // Verify the text was entered
    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.text('123456'), findsOneWidget);

    // Tap the login button
    await tester.tap(loginButton);
    await tester.pump();

    // Verify the button still exists
    expect(loginButton, findsOneWidget);
  });
}
