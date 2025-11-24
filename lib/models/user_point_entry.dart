import 'package:cloud_firestore/cloud_firestore.dart';

class UserPointEntry {
  final DateTime timestamp;
  final int points;

  UserPointEntry({required this.timestamp, required this.points});

  factory UserPointEntry.fromMap(Map<String, dynamic> map) {
    final ts = map['timestamp'];

    return UserPointEntry(
      timestamp:
          ts is Timestamp
              ? ts.toDate()
              : DateTime.fromMillisecondsSinceEpoch(0), // fallback
      points:
          map['points'] is int
              ? map['points']
              : int.tryParse(map['points'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'timestamp': timestamp, 'points': points};
  }

  factory UserPointEntry.fromJson(Map<String, dynamic> json) {
    return UserPointEntry(
      timestamp: DateTime.parse(json['timestamp']),
      points: json['points'],
    );
  }

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'points': points,
  };
}
