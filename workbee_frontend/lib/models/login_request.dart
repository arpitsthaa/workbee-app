class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  /// Converts the request into a JSON map for your API call
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}