import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jerseypasal/features/onboarding/presentation/pages/Jersey_Onboarding1_Screen.dart';
import 'package:jerseypasal/features/onboarding/presentation/pages/Jersey_Onboarding2_Screen.dart';

void main() {
  testWidgets(
    'JerseyOnboarding1Screen displays title, images, and Next button',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: JerseyOnboarding1Screen()),
      );
      expect(find.text('JERSEYपसल'), findsOneWidget);
      expect(find.text('WELCOME TO JERSEYPASAL'), findsOneWidget);

      final nextButton = find.widgetWithText(ElevatedButton, 'Next');
      expect(nextButton, findsOneWidget);

      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      expect(find.byType(JerseyOnboarding2Screen), findsOneWidget);
    },
  );
}
