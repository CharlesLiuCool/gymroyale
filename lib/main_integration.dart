import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart'; // from FlutterFire CLI
import 'main.dart';          // wraps AuthGate etc.

Future<void> _ensureFirebaseInitializedForTests() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // IMPORTANT:
    // When running on Android emulator, host should be 10.0.2.2
    // Port comes from firebase.json ("auth": { "port": 9099 })
    FirebaseAuth.instance.useAuthEmulator('10.0.2.2', 9099);
  }
}

Future<void> main() async {
  await _ensureFirebaseInitializedForTests();
  runApp(const MyApp());
}

/// Export this so tests can reuse it without double-initializing
Future<void> ensureFirebaseInitializedForTests() =>
    _ensureFirebaseInitializedForTests();