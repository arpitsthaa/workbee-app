class BusinessRegistrationRequest {
  final String businessName;
  final String contactPerson;
  final String email;
  final String phone;
  final String location;
  final String panNumber;
  final String password;
  final String confirmPassword;

  BusinessRegistrationRequest({
    required this.businessName,
    required this.contactPerson,
    required this.email,
    required this.phone,
    required this.location,
    required this.panNumber,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'business_name': businessName,
      'contact_person': contactPerson,
      'email': email,
      'phone': phone,
      'location': location,
      'pan_number': panNumber,
      'password': password,
      'confirm_password': confirmPassword,
    };
  }
}

class BusinessRegistrationResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  BusinessRegistrationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory BusinessRegistrationResponse.fromJson(
      Map<String, dynamic> json,
      int statusCode,
      ) {
    return BusinessRegistrationResponse(
      success: statusCode == 200 || statusCode == 201,
      message: json['message'] ?? 'Business account created successfully!',
      data: json,
    );
  }
}