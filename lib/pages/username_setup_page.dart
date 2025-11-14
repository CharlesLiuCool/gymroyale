import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/leaderboard_repository.dart';
import '../auth_gate.dart'; // <-- import this

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

    // 🔥 IMPORTANT: Go back to AuthGate so it re-checks Firestore
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthGate()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose a Username')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _submitUsername,
              child:
                  _loading
                      ? const CircularProgressIndicator()
                      : const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
