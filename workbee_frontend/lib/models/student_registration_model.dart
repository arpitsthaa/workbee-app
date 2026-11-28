class StudentRegistrationRequest {
  final String fullName;
  final String email;
  final String password;
  final String collegeUniversity;

  StudentRegistrationRequest({
    required this.fullName,
    required this.email,
    required this.password,
    required this.collegeUniversity,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'password': password,
      'college_university': collegeUniversity,
    };
  }
}

class StudentRegistrationResponse {
  final bool success;
  final String message;
  final String? token;
  final Map<String, dynamic>? userData;

  StudentRegistrationResponse({
    required this.success,
    required this.message,
    this.token,
    this.userData,
  });

  factory StudentRegistrationResponse.fromJson(
      Map<String, dynamic> json,
      int statusCode,
      ) {
    final isSuccess = statusCode == 200 || statusCode == 201;
    return StudentRegistrationResponse(
      success: isSuccess,
      message: json['message'] ??
          (isSuccess
              ? 'Student account created successfully.'
              : 'Registration failed. Please check your details.'),
      token: json['token']?.toString(),
      userData: json['user'] is Map<String, dynamic> ? json['user'] : null,
    );
  }
}