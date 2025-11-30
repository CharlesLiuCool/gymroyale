import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../repositories/leaderboard_repository.dart';
import '../theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// CONFIG:
// Minimum distance in meters to be considered "at the gym"
// Easy to toggle for testing
const double minDistance = 200;
// Disable gym checkin for testing
const bool disableCheck = true;

class GymCheckInButton extends StatefulWidget {
  final String userId;
  final LeaderboardRepository repo;

  const GymCheckInButton({super.key, required this.userId, required this.repo});

  @override
  State<GymCheckInButton> createState() => _GymCheckInButtonState();
}

class _GymCheckInButtonState extends State<GymCheckInButton> {
  bool _checking = false;
  double? _distanceMeters;

  final double gymLat = 46.73746;
  final double gymLng = -117.15440;

  Future _checkIn() async {
    setState(() {
      _checking = true;
    });

    try {
      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showNotification("Location permission is required.");
        setState(() => _checking = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 1,
        ),
      );

      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        gymLat,
        gymLng,
      );

      setState(() => _distanceMeters = distance);

      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId);

      final doc = await userRef.get();
      final data = doc.data();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final lastCheckIn = (data?['lastCheckIn'] as Timestamp?)?.toDate();
      final lastDate =
          lastCheckIn != null
              ? DateTime(lastCheckIn.year, lastCheckIn.month, lastCheckIn.day)
              : null;

      final diff = lastDate != null ? today.difference(lastDate).inDays : null;

      // check distance
      if (!disableCheck && distance > minDistance) {
        _showNotification(
          "You're too far from the gym (${distance.toStringAsFixed(1)} m)",
        );
      }
      // already checked in
      else if (!disableCheck && diff == 0) {
        _showNotification("You've already checked in today!");
      }
      // diff == null is first sign-in case, diff == 1 is checked in yesterday
      else if (disableCheck || diff == null || diff >= 1) {
        final streak = await updateStreak(widget.userId);
        final points = 10 + 5 * streak;

        await widget.repo.addPoints(widget.userId, points);
        _showNotification(
          "Checked in at the gym! +$points points (Streak: $streak)",
        );
      }
    } catch (e) {
      _showNotification("Error: $e");
    }

    setState(() => _checking = false);
  }

  void _showNotification(String message) {
    // Show a small notification at the top-right using ScaffoldMessenger
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(0, 8, 16, 0),
          backgroundColor: AppColors.accent,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<int> updateStreak(String userId) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final doc = await userRef.get();
    final data = doc.data();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final lastCheckIn = (data?['lastCheckIn'] as Timestamp?)?.toDate();
    final lastDate =
        lastCheckIn != null
            ? DateTime(lastCheckIn.year, lastCheckIn.month, lastCheckIn.day)
            : null;

    int newStreak = 1;

    if (lastDate != null) {
      final diff = today.difference(lastDate).inDays;
      if (diff == 1) {
        newStreak = (data?['streakCount'] ?? 0) + 1;
      } else if (diff == 0) {
        newStreak = data?['streakCount'] ?? 1; // already checked in today
      }
    }

    await userRef.update({
      'streakCount': newStreak,
      'lastCheckIn': Timestamp.fromDate(now),
    });

    return newStreak;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _checking ? null : _checkIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                _checking
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.textPrimary,
                        strokeWidth: 2,
                      ),
                    )
                    : const Text(
                      "Check In at Gym",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}
