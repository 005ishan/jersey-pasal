import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jerseypasal/features/onboarding/presentation/pages/Jersey_Onboarding1_Screen.dart';
import 'package:jerseypasal/features/splash/presentation/pages/Jersey_Splash_Screen.dart';
import 'package:jerseypasal/core/services/storage/user_session_service.dart';

class MockUserSessionService implements UserSessionService {
  final bool loggedIn;

  MockUserSessionService({required this.loggedIn});

  @override
  bool isLoggedIn() => loggedIn;

  // Implement all abstract methods as no-op / null-returning
  @override
  Future<void> clearSession() async {}

  @override
  Future<void> saveUserSession({
    required String userId,
    required String email,
    String? profilePicture,
    String? token,
  }) async {}

  @override
  String? getUserId() => null;

  @override
  String? getUserEmail() => null;

  @override
  String? getUserProfileImage() => null;

  @override
  Future<String?> getAuthToken() async => null;
}

void main() {
  testWidgets(
    'SplashScreen shows title and navigates to Onboarding when not logged in',
    (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          userSessionServiceProvider.overrideWithValue(
            MockUserSessionService(loggedIn: false),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: JerseySplashScreen()),
        ),
      );

      // Check splash text
      expect(find.text('JERSEYपसल'), findsOneWidget);
      expect(find.text('Authentic Football Jerseys'), findsOneWidget);

      // Wait for navigation
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.byType(JerseyOnboarding1Screen), findsOneWidget);
    },
  );
}
