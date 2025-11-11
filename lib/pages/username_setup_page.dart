import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/leaderboard_repository.dart';
import 'main_page.dart';

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

    // Check if user already exists in leaderboard
    final exists = await widget.repo.userExists(widget.userId);

    if (!exists) {
      // Brand new user: add to leaderboard and Firestore with points = 0
      await widget.repo.addUser(widget.userId, username, 0);
    } else {
      // Existing user: ensure 'points' field exists
      await userRef.set({
        'name': username,
        'points': FieldValue.increment(0),
      }, SetOptions(merge: true));
    }

    setState(() => _loading = false);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainPage(userId: widget.userId, repo: widget.repo),
        ),
      );
    }
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
