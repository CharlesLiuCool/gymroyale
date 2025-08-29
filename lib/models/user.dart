class User {
  final String id;
  final String name;
  final int points;
  final int? rank;

  User({required this.id, required this.name, required this.points, this.rank});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      points: json['points'] as int,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'points': points};
}
