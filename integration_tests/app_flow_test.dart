import 'package:flutter_test/flutter_test.dart';
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
    // This main() uses the emulator-configured Firebase
    await app.main();

    // Let the widget tree build and AuthGate react to auth state
    await tester.pumpAndSettle();

    // AuthGate should route past LoginPage into your main UI
    expect(find.text('Gym Royale'), findsOneWidget);

    // From here you can test tabs, workouts, etc.
    // e.g. expect(find.text('Leaderboard (coming soon)'), findsNothing);
  });
}