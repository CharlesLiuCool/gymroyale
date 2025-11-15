import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/leaderboard_repository.dart';
import '../auth_gate.dart';
import '../app_colors.dart';

class UsernameSetupPage extends StatefulWidget {
  final String userId;
  final LeaderboardRepository repo;

  const UsernameSetupPage({
    super.key,
    required this.userId,
    required this.repo,
  });

  @override
  State<UsernameSetupPage> createState() => _UsernameSetupPageState();
}

class _UsernameSetupPageState extends State<UsernameSetupPage> {
  final _controller = TextEditingController();
  bool _loading = false;

  Future<void> _submitUsername() async {
    final username = _controller.text.trim();
    if (username.isEmpty) return;

    setState(() => _loading = true);

    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId);

    await userRef.set({
      'name': username,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await widget.repo.addPoints(widget.userId, 0);

    setState(() => _loading = false);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthGate()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        title: const Text(
          'Choose a Username',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              style: const TextStyle(color: AppColors.textPrimary),
              cursorColor: AppColors.accent,
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.textSecondary),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.accent),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _submitUsername,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.textPrimary,
              ),
              child:
                  _loading
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textPrimary,
                        ),
                      )
                      : const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
