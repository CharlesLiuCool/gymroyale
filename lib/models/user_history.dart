import 'user_point_entry.dart';

class UserHistory {
  final String userId;
  final String name;
  final List<UserPointEntry> history;

  UserHistory({
    required this.userId,
    required this.name,
    required this.history,
  });

  // Sort history by timestamp ascending for graphing
  UserHistory sorted() {
    final sortedHistory = [...history]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return UserHistory(userId: userId, name: name, history: sortedHistory);
  }
}
