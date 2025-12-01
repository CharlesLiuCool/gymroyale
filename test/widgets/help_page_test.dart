import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymroyale/pages/main/settings/help_page.dart';

void main() {
  testWidgets('HelpPage shows FAQ items', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: HelpPage()),
    );

    expect(find.text('Welcome to Gym Royale Help!'), findsOneWidget);
    expect(find.text('How do I log workouts?'), findsOneWidget);
    expect(find.text('How does the leaderboard work?'), findsOneWidget);
    expect(find.text('Need more help?'), findsOneWidget);
  });
}