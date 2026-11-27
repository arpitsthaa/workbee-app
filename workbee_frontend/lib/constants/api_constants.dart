/// API configuration constants for the WorkBee backend.
class ApiConstants {
  /// Base URL for the Django backend. Override with --dart-define=API_BASE_URL=...
  static const String baseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'https://workbee-app.onrender.com');

  /// Authentication endpoints
  static const String registerStudent = '/api/users/register/student/';
  static const String registerBusiness = '/api/users/register/business/';
  static const String login = '/api/users/login/';

  /// Student endpoints
  static const String studentDashboard = '/api/student/dashboard/';
  static const String studentDashboardProfile = '/api/student/dashboard/profile/';
  static const String studentDashboardGigs = '/api/student/dashboard/gigs/';
  static const String studentDashboardSummary = '/api/student/dashboard/summary/';
  static const String studentGigs = '/api/student/gigs/';
  static const String studentGigDetail = '/api/student/gigs/';
  static const String studentApplyGig = '/api/student/gigs/';
  static const String studentWork = '/api/student/work/';
  static const String studentWorkApplications = '/api/student/work/applications/';
  static const String studentWorkProjects = '/api/student/work/projects/';
  static const String studentWorkSubmit = '/api/student/work/projects/';
  static const String studentWorkUpdateStatus = '/api/student/work/projects/';
  static const String studentPassport = '/api/student/passport/';
  static const String studentProfile = '/api/student/profile/';
  static const String studentApplyGigById = '/api/student/gigs/';
  static const String studentWithdrawApplication = '/api/student/applications/';

  /// Business endpoints
  static const String businessDashboard = '/api/business/dashboard/';
  static const String businessProfile = '/api/business/profile/';
  static const String businessGigs = '/api/business/gigs/';
  static const String businessGigById = '/api/business/gigs/';
  static const String businessProjects = '/api/business/projects/';
  static const String businessApplicationsStatus = '/api/business/applications/';
  static const String businessReviewWork = '/api/business/projects/';
  static const String businessRateStudent = '/api/business/projects/';

  /// Health check
  static const String health = '/api/health/';
}
