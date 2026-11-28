class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String token;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userObj = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : json;

    return UserModel(
      id: (userObj['id'] ?? json['id'] ?? '').toString(),
      fullName: (userObj['full_name'] ?? userObj['name'] ?? '').toString(),
      email: (userObj['email'] ?? json['email'] ?? '').toString(),
      role: (userObj['role'] ?? json['role'] ?? 'student').toString().toLowerCase(),
      token: (json['token'] ?? json['access'] ?? '').toString(),
    );
  }
}