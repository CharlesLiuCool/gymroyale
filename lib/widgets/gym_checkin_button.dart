import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../repositories/leaderboard_repository.dart';
import '../app_colors.dart';

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

      if (distance <= 200) {
        await widget.repo.addPoints(widget.userId, 10);
        _showNotification("Checked in at the gym! +10 points");
      } else {
        _showNotification(
          "You’re too far from the gym (${distance.toStringAsFixed(1)} m)",
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
