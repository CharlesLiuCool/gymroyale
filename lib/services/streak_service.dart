import 'package:cloud_firestore/cloud_firestore.dart';

Future<int> updateStreak(
  String userId, {
  FirebaseFirestore? firestore,
  DateTime? now,
}) async {
  final db = firestore ?? FirebaseFirestore.instance;
  final userRef = db.collection('users').doc(userId);

  final doc = await userRef.get();
  final data = doc.data();

  final currentTime = now ?? DateTime.now();
  final today = DateTime(currentTime.year, currentTime.month, currentTime.day);

  final lastCheckIn = (data?['lastCheckIn'] as Timestamp?)?.toDate();
  final lastDate =
      lastCheckIn != null
          ? DateTime(lastCheckIn.year, lastCheckIn.month, lastCheckIn.day)
          : null;

  int newStreak;

  if (lastDate == null) {
    newStreak = 1;
  } else {
    final diff = today.difference(lastDate).inDays;

    if (diff == 0) {
      newStreak = data?['streakCount'] ?? 1;
    } else if (diff == 1) {
      newStreak = (data?['streakCount'] ?? 0) + 1;
    } else {
      newStreak = 0;
    }
  }

  await userRef.update({
    'streakCount': newStreak,
    'lastCheckIn': Timestamp.fromDate(currentTime),
  });

  return newStreak;
}
