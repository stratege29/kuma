import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuma/main.dart';

void main() {
  testWidgets('KumaApp launches with onboarding page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KumaApp());

    // Wait for any animations to complete
    await tester.pumpAndSettle();

    // Verify that the onboarding page is displayed
    expect(find.text('KUMA'), findsWidgets);
    expect(find.text('Passer'), findsOneWidget);

    // Verify the first onboarding screen content (Welcome page)
    expect(find.text('Bienvenue sur'), findsOneWidget);
  });

  testWidgets('Skip button navigates to home page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KumaApp());
    await tester.pump();

    // Find and tap the skip button
    final skipButton = find.text('Passer');
    expect(skipButton, findsOneWidget);
    
    await tester.tap(skipButton);
    await tester.pump();

    // Wait a bit for navigation
    await tester.pump(const Duration(milliseconds: 500));

    // Verify navigation to home page by checking for home page elements
    // The home page should display the navigation bar with Carte
    expect(find.text('Carte'), findsOneWidget);
  });
}