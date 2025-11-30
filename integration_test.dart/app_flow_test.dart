import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:gymroyale/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('new user login + username setup', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // On LoginPage
    expect(find.text('Sign in with Google'), findsOneWidget);

    // I'll change this later to either stub Google sign-in or run against a test environment.
    // For now, it just asserts that tapping the button shows loading.
    await tester.tap(find.text('Sign in with Google'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}