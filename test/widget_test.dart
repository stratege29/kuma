import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuma/features/onboarding/presentation/pages/onboarding_page.dart';

void main() {
  testWidgets('Onboarding page launches correctly', (WidgetTester tester) async {
    // Build the onboarding page directly (without auth wrapper for testing)
    await tester.pumpWidget(const MaterialApp(home: OnboardingPage()));

    // Wait for any animations to complete
    await tester.pumpAndSettle();

    // Verify that the onboarding page is displayed
    expect(find.text('KUMA'), findsWidgets);
    expect(find.text('Passer'), findsOneWidget);

    // Verify the first onboarding screen content (Welcome page)
    expect(find.text('Bienvenue sur'), findsOneWidget);
  });

  testWidgets('Onboarding navigation works', (WidgetTester tester) async {
    // Build the onboarding page directly
    await tester.pumpWidget(const MaterialApp(home: OnboardingPage()));
    await tester.pumpAndSettle();

    // Verify initial page
    expect(find.text('Bienvenue sur'), findsOneWidget);
    
    // Find and verify skip button exists
    final skipButton = find.text('Passer');
    expect(skipButton, findsOneWidget);
    
    // Verify next button exists
    final nextButton = find.text('Suivant');
    expect(nextButton, findsOneWidget);
  });
}