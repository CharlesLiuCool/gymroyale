import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:gymroyale/main_integration.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Init Firebase + point to emulator (idempotent)
    await app.ensureFirebaseInitializedForTests();

    // Create a dummy user in the Auth emulator (first run only)
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: 'testuser@gymroyale.dev',
        password: 'password123',
      );
    } on FirebaseAuthException catch (e) {
      if (e.code != 'email-already-in-use') rethrow;
    }

    // Sign in as that user on the emulator
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: 'testuser@gymroyale.dev',
      password: 'password123',
    );

    // At this point FirebaseAuth.instance.currentUser is non-null,
    // and authStateChanges() will emit a logged-in user.
  });

  testWidgets('starts app with authenticated emulator user', (tester) async {
    // Boot app using emulator-config main
    await app.main();

    // Let it build and navigate based on auth state
    await tester.pumpAndSettle();

    // 1. We should be on UsernameSetupPage first
    expect(find.text('Choose a Username'), findsOneWidget);

    // 2. Enter a username
    await tester.enterText(find.byType(TextField), 'TestUser');

    // 3. Tap "Continue"
    await tester.tap(find.text('Continue'));

    // 4. Wait for Firestore write + navigation to complete
    await tester.pumpAndSettle();

    // AuthGate saw an authenticated emulator user
    // and routed to UsernameSetupPage
    expect(find.text('Choose a Username'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}