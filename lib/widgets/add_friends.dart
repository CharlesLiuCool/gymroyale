import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymroyale/theme/app_colors.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'qr_scanner_tab.dart';

class AddFriendsPage extends StatefulWidget {
  final String userId;

  const AddFriendsPage({super.key, required this.userId});

  @override
  State<AddFriendsPage> createState() => _AddFriendsPageState();
}

class _AddFriendsPageState extends State<AddFriendsPage> {
  bool _loading = false;
  String? _error;

  Future<void> _addFriendById(String friendId) async {
    if (friendId == widget.userId) {
      setState(() => _error = "You cannot add yourself");
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .update({
            "friends": FieldValue.arrayUnion([friendId]),
          });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Friend added!")));
      }
    } catch (e) {
      setState(() => _error = "Failed to add friend");
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            "Add Friends",
            style: TextStyle(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.card,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          bottom: const TabBar(
            indicatorColor: AppColors.accent,
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [Tab(text: "My QR"), Tab(text: "Scan QR")],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: Show user’s QR code
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Your QR Code",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  QrImageView(
                    data: widget.userId,
                    version: QrVersions.auto,
                    size: 200,
                    foregroundColor: AppColors.textPrimary,
                  ),
                ],
              ),
            ),

            // TAB 2: Scan a friend’s QR
            QRScannerTab(
              onScan: _addFriendById,
              errorCallback: (err) {
                setState(() => _error = err);
              },
            ),
          ],
        ),
      ),
    );
  }
}
