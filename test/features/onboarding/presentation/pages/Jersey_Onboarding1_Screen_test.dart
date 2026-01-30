import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jerseypasal/features/onboarding/presentation/pages/Jersey_Onboarding1_Screen.dart';
import 'package:jerseypasal/features/onboarding/presentation/pages/Jersey_Onboarding2_Screen.dart';

void main() {
  testWidgets(
    'JerseyOnboarding1Screen displays title, images, and Next button',
    (WidgetTester tester) async {
      // Load the widget  
      await tester.pumpWidget(
        const MaterialApp(home: JerseyOnboarding1Screen()),
      );

      // Check if title text is present
      expect(find.text('JERSEYपसल'), findsOneWidget);
      expect(find.text('WELCOME TO JERSEYPASAL'), findsOneWidget);

      // Check if the Next button is present
      final nextButton = find.widgetWithText(ElevatedButton, 'Next');
      expect(nextButton, findsOneWidget);

      // Tap the Next button and verify navigation
      await tester.tap(nextButton);
      await tester.pumpAndSettle(); // wait for navigation animation

      // Verify that we navigated to JerseyOnboarding2Screen
      expect(find.byType(JerseyOnboarding2Screen), findsOneWidget);
    },
  );
}
