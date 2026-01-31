import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jerseypasal/features/onboarding/presentation/pages/Jersey_Onboarding2_Screen.dart';
import 'package:jerseypasal/features/onboarding/presentation/pages/Jersey_Onboarding3_Screen.dart';

void main() {
  testWidgets(
    'JerseyOnboarding2Screen displays title, images, and navigates to Onboarding3',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: JerseyOnboarding2Screen()),
      );

      expect(find.text('JERSEYपसल'), findsOneWidget);
      expect(find.text('CHOOSE YOUR TEAM'), findsOneWidget);
      expect(
        find.text(
          'Find jerseys from all your favorite clubs and national teams.',
        ),
        findsOneWidget,
      );

      expect(find.byType(Image), findsNWidgets(3));

      final nextButton = find.widgetWithText(ElevatedButton, 'Next');
      expect(nextButton, findsOneWidget);

      await tester.tap(nextButton);
      await tester.pumpAndSettle(); 

      expect(find.byType(JerseyOnboarding3Screen), findsOneWidget);
    },
  );
}
