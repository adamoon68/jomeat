class User {
  final int userId;
  final String name;
  final String email;
  final String role;

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: int.parse(json['user_id'].toString()),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'student',
    );
  }
}
