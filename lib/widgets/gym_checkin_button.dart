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
  String? _message;
  double? _distanceMeters;

  final double gymLat = 46.73746;
  final double gymLng = -117.15440;

  Future _checkIn() async {
    setState(() {
      _checking = true;
      _message = null;
    });

    try {
      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _message = "Location permission is required.";
          _checking = false;
        });
        return;
      }

      LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 1,
      );

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        gymLat,
        gymLng,
      );

      setState(() {
        _distanceMeters = distance;
      });

      if (distance <= 200) {
        await widget.repo.addPoints(widget.userId, 10);

        setState(() {
          _message = "Checked in at the gym! +10 points";
        });
      } else {
        setState(() {
          _message =
              "You’re too far from the gym. (${distance.toStringAsFixed(1)} m)";
        });
      }
    } catch (e) {
      setState(() {
        _message = "Error: $e";
      });
    }

    setState(() {
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end, // align content at bottom
          crossAxisAlignment: CrossAxisAlignment.center, // center horizontally
          children: [
            SizedBox(
              width: double.infinity, // ensures button fills padding width
              child: Center(
                // ensures button stays centered regardless of parent
                child: ElevatedButton(
                  onPressed: _checking ? null : _checkIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 24,
                    ),
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 8),
              Text(
                _message!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
            if (_distanceMeters != null) ...[
              const SizedBox(height: 4),
              Text(
                "Distance to gym: ${_distanceMeters!.toStringAsFixed(1)} m",
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
