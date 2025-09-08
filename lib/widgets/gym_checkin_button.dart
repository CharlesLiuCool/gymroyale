import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';

class GymCheckInButton extends StatefulWidget {
  const GymCheckInButton({super.key});

  @override
  State createState() => _GymCheckInButtonState();
}

class _GymCheckInButtonState extends State {
  bool _checking = false;

  String? _message;

  double? _distanceMeters;

  final double gymLat = 46.73746; // replace with your gym latitude

  final double gymLng = -117.15440; // replace with your gym longitude

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

        if (distance <= 200) {
          _message = "Checked in at the gym!";
        } else {
          _message =
              "You’re too far from the gym. (${distance.toStringAsFixed(1)} m)";
        }
      });
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
    return Column(
      mainAxisSize: MainAxisSize.min,

      children: [
        ElevatedButton(
          onPressed: _checking ? null : _checkIn,

          child:
              _checking
                  ? const SizedBox(
                    width: 16,

                    height: 16,

                    child: CircularProgressIndicator(
                      color: Colors.white,

                      strokeWidth: 2,
                    ),
                  )
                  : const Text("Check In at Gym"),
        ),

        if (_message != null) ...[const SizedBox(height: 8), Text(_message!)],

        if (_distanceMeters != null) ...[
          const SizedBox(height: 4),

          Text("Distance to gym: ${_distanceMeters!.toStringAsFixed(1)} m"),
        ],
      ],
    );
  }
}
