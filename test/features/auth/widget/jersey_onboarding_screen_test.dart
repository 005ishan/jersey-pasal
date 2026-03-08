import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jerseypasal/features/onboarding/presentation/pages/Jersey_Onboarding_Screen.dart';

void main() {
  Widget createWidget() {
    return const MaterialApp(
      home: JerseyOnboardingScreen(),
    );
  }

  // ─────────────────────────────────────────────

  testWidgets('1. Renders first page headline',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidget());

    expect(find.text('Welcome to\nJERSEYपसल'), findsOneWidget);
  });

  // ─────────────────────────────────────────────

  testWidgets('2. Shows Skip button on first page',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidget());

    expect(find.text('Skip'), findsOneWidget);
  });

  // ─────────────────────────────────────────────

  testWidgets('3. Tapping Next moves to second page',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidget());

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Choose Your\nTeam'), findsOneWidget);
  });

  // ─────────────────────────────────────────────

  testWidgets('4. Button changes to Get Started on last page',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidget());

    // Go to page 2
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Go to page 3
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Get Started'), findsOneWidget);
  });

  // ─────────────────────────────────────────────

  testWidgets('5. Page dots update when swiping',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidget());

    // Swipe left to go to next page
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(find.text('Choose Your\nTeam'), findsOneWidget);
  });
}