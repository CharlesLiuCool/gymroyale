import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../repositories/leaderboard_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'username_setup_page.dart';
import 'main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isSigningIn = false;
  final googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle() async {
    setState(() => _isSigningIn = true);

    // --- Force sign-out & safe disconnect (for testing multiple accounts) ---
    try {
      await googleSignIn.signOut();
      try {
        await googleSignIn.disconnect();
      } catch (e) {
        debugPrint('No existing Google session to disconnect: $e');
      }
    } catch (e) {
      debugPrint('Error during pre sign-out: $e');
    }

    try {
      // --- Start Google sign-in flow ---
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isSigningIn = false);
        return; // user canceled
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = userCredential.user!;
      final repo = LeaderboardRepository();

      // --- Fetch or create user document ---
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      final doc = await docRef.get();
      final data = doc.data();

      final hasName =
          data != null &&
          data['name'] != null &&
          data['name'].toString().isNotEmpty;

      debugPrint('Firestore user doc: ${data ?? "no data"}');
      debugPrint('Has name? $hasName');

      if (!doc.exists || !hasName) {
        // Create user document if missing
        if (!doc.exists) {
          await docRef.set({
            'email': user.email,
            'name': '',
            'points': 0,
            'photoUrl': user.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => UsernameSetupPage(userId: user.uid, repo: repo),
            ),
          );
        }
      } else {
        // Returning user → ensure leaderboard entry exists
        await repo.addPoints(user.uid, 0);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MainPage(userId: user.uid, repo: repo),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sign-in failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            _isSigningIn
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                  icon: Image.asset('assets/google_logo.png', height: 24),
                  label: const Text('Sign in with Google'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onPressed: signInWithGoogle,
                ),
      ),
    );
  }
}
