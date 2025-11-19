// lib/widgets/settings_menu.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gymroyale/pages/help_page.dart';
import 'package:gymroyale/pages/profile_page.dart';
import '../theme/app_colors.dart';

class SettingsMenu extends StatelessWidget {
  const SettingsMenu({super.key});

  /// Proper sign-out handling for Firebase + Google
  Future<void> _signOut() async {
    final googleSignIn = GoogleSignIn();

    try {
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.disconnect(); // clear cached account
      }
    } catch (e) {
      debugPrint("Google disconnect error: $e");
    }

    await FirebaseAuth.instance.signOut();
    // Navigation handled by auth state listener in your app
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.settings, color: AppColors.textPrimary),
      onSelected: (value) {
        switch (value) {
          case 'signout':
            _signOut();
            break;
          case 'profile':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
            break;
          case 'help':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HelpPage()),
            );
            break;
        }
      },
      itemBuilder:
          (context) => const [
            PopupMenuItem(value: 'profile', child: Text('Profile')),
            PopupMenuItem(value: 'help', child: Text('Help')),
            PopupMenuItem(value: 'signout', child: Text('Sign Out')),
          ],
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
