class User {
  final String id;
  final String name;
  final int points;
  final int? rank; // optional, assigned in UI

  User({required this.id, required this.name, required this.points, this.rank});

  /// Create User from Firestore document map
  factory User.fromMap(Map<String, dynamic> map, String id) {
    return User(
      id: id,
      name: map['name'] as String? ?? 'User',
      points:
          map['points'] is int
              ? map['points'] as int
              : int.tryParse(map['points'].toString()) ?? 0,
    );
  }

  /// Convert User to map for Firestore
  Map<String, dynamic> toMap() {
    return {'name': name, 'points': points};
  }

  /// Optional copyWith for updating fields
  User copyWith({String? id, String? name, int? points, int? rank}) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      points: points ?? this.points,
      rank: rank ?? this.rank,
    );
  }

  /// JSON serialization (optional)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      points: json['points'] as int,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'points': points};
}
