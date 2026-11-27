class Gig {
  final int id;
  final String businessName;
  final String title;
  final String category;
  final List<String> requiredSkills;
  final int budgetNpr;
  final int durationDays;
  final String deadline;
  final String location;
  final bool isRemote;
  final String status;
  final int applicantsCount;
  final bool hasApplied;
  final String createdAt;

  Gig({
    required this.id,
    required this.businessName,
    required this.title,
    required this.category,
    required this.requiredSkills,
    required this.budgetNpr,
    required this.durationDays,
    required this.deadline,
    required this.location,
    required this.isRemote,
    required this.status,
    required this.applicantsCount,
    required this.hasApplied,
    required this.createdAt,
  });

  factory Gig.fromJson(Map<String, dynamic> json) {
    return Gig(
      id: json['id'] ?? 0,
      businessName: (json['business_name'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      category: (json['category'] ?? '') as String,
      requiredSkills: List<String>.from(json['required_skills'] ?? []),
      budgetNpr: (json['budget_npr'] ?? 0) as int,
      durationDays: (json['duration_days'] ?? 0) as int,
      deadline: (json['deadline'] ?? '') as String,
      location: (json['location'] ?? '') as String,
      isRemote: json['is_remote'] ?? true,
      status: (json['status'] ?? '') as String,
      applicantsCount: (json['applicants_count'] ?? 0) as int,
      hasApplied: json['has_applied'] ?? false,
      createdAt: (json['created_at'] ?? '') as String,
    );
  }
}

class GigApplication {
  final int id;
  final int gig;
  final String gigTitle;
  final String businessName;
  final int student;
  final String studentName;
  final String studentCollege;
  final List<String> studentSkills;
  final double studentRating;
  final int verifiedProjectsCount;
  final String coverMessage;
  final String status;
  final String appliedAt;

  GigApplication({
    required this.id,
    required this.gig,
    required this.gigTitle,
    required this.businessName,
    required this.student,
    required this.studentName,
    required this.studentCollege,
    required this.studentSkills,
    required this.studentRating,
    required this.verifiedProjectsCount,
    required this.coverMessage,
    required this.status,
    required this.appliedAt,
  });

  factory GigApplication.fromJson(Map<String, dynamic> json) {
    return GigApplication(
      id: json['id'] ?? 0,
      gig: json['gig'] ?? 0,
      gigTitle: (json['gig_title'] ?? '') as String,
      businessName: (json['business_name'] ?? '') as String,
      student: json['student'] ?? 0,
      studentName: (json['student_name'] ?? '') as String,
      studentCollege: (json['student_college'] ?? '') as String,
      studentSkills: List<String>.from(json['student_skills'] ?? []),
      studentRating: (json['student_rating'] ?? 0.0) as double,
      verifiedProjectsCount: (json['verified_projects_count'] ?? 0) as int,
      coverMessage: (json['cover_message'] ?? '') as String,
      status: (json['status'] ?? '') as String,
      appliedAt: (json['applied_at'] ?? '') as String,
    );
  }
}

class Project {
  final int id;
  final int gig;
  final String gigTitle;
  final int budgetNpr;
  final String deadline;
  final List<String> deliverables;
  final String businessName;
  final String studentName;
  final String status;
  final String submissionLink;
  final String submissionNote;
  final String? submittedAt;
  final String? completedAt;
  final bool hasReview;
  final String createdAt;

  Project({
    required this.id,
    required this.gig,
    required this.gigTitle,
    required this.budgetNpr,
    required this.deadline,
    required this.deliverables,
    required this.businessName,
    required this.studentName,
    required this.status,
    required this.submissionLink,
    required this.submissionNote,
    this.submittedAt,
    this.completedAt,
    required this.hasReview,
    required this.createdAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] ?? 0,
      gig: json['gig'] ?? 0,
      gigTitle: (json['gig_title'] ?? '') as String,
      budgetNpr: (json['budget_npr'] ?? 0) as int,
      deadline: (json['deadline'] ?? '') as String,
      deliverables: List<String>.from(json['deliverables'] ?? []),
      businessName: (json['business_name'] ?? '') as String,
      studentName: (json['student_name'] ?? '') as String,
      status: (json['status'] ?? '') as String,
      submissionLink: (json['submission_link'] ?? '') as String,
      submissionNote: (json['submission_note'] ?? '') as String,
      submittedAt: json['submitted_at'] as String?,
      completedAt: json['completed_at'] as String?,
      hasReview: json['has_review'] ?? false,
      createdAt: (json['created_at'] ?? '') as String,
    );
  }
}

/// Parses a rating value that may come as a double or a String from the API.
double _parseRating(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

class ProjectReview {
  final int id;
  final int project;
  final String gigTitle;
  final String businessName;
  final String businessLocation;
  final String roleTitle;
  final List<String> skills;
  final int durationDays;
  final double rating;
  final String reviewComment;
  final String? submissionLink;
  final String? completedAt;
  final String createdAt;

  ProjectReview({
    required this.id,
    required this.project,
    required this.gigTitle,
    required this.businessName,
    required this.businessLocation,
    required this.roleTitle,
    required this.skills,
    required this.durationDays,
    required this.rating,
    required this.reviewComment,
    this.submissionLink,
    this.completedAt,
    required this.createdAt,
  });

  factory ProjectReview.fromJson(Map<String, dynamic> json) {
    return ProjectReview(
      id: json['id'] ?? 0,
      project: json['project'] ?? 0,
      gigTitle: (json['gig_title'] ?? '') as String,
      businessName: (json['business_name'] ?? '') as String,
      businessLocation: (json['business_location'] ?? '') as String,
      roleTitle: (json['role_title'] ?? '') as String,
      skills: List<String>.from(json['skills'] ?? []),
      durationDays: (json['duration_days'] ?? 0) as int,
      rating: _parseRating(json['rating'] ?? 0.0),
      reviewComment: (json['review_comment'] ?? '') as String,
      submissionLink: json['submission_link'] as String?,
      completedAt: json['completed_at'] as String?,
      createdAt: (json['created_at'] ?? '') as String,
    );
  }
}

class PassportResponse {
  final String fullName;
  final String? collegeUniversity;
  final String program;
  final int verifiedProjectsCount;
  final double averageRating;
  final List<ProjectReview> completedProjects;

  PassportResponse({
    required this.fullName,
    this.collegeUniversity,
    required this.program,
    required this.verifiedProjectsCount,
    required this.averageRating,
    required this.completedProjects,
  });

  factory PassportResponse.fromJson(Map<String, dynamic> json) {
    return PassportResponse(
      fullName: (json['full_name'] ?? 'Student') as String,
      collegeUniversity: json['college_university'] as String?,
      program: (json['program'] ?? '') as String,
      verifiedProjectsCount: (json['verified_projects_count'] ?? 0) as int,
      averageRating: _parseRating(json['average_rating'] ?? 0.0),
      completedProjects: (json['completed_projects'] as List<dynamic>?)
              ?.map((p) => ProjectReview.fromJson(p as Map<String, dynamic>))
              .toList() ?? []
    );
  }
}

class ProfileResponse {
  final int id;
  final String fullName;
  final String email;
  final String? collegeUniversity;
  final String? location;
  final String program;
  final String semester;
  final String bio;
  final List<String> skills;
  final String portfolioUrl;
  final bool isVerified;
  final int profileCompletion;

  ProfileResponse({
    required this.id,
    required this.fullName,
    required this.email,
    this.collegeUniversity,
    this.location,
    required this.program,
    required this.semester,
    required this.bio,
    required this.skills,
    required this.portfolioUrl,
    required this.isVerified,
    required this.profileCompletion,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      id: json['id'] ?? 0,
      fullName: (json['full_name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      collegeUniversity: json['college_university'] as String?,
      location: json['location'] as String?,
      program: (json['program'] ?? '') as String,
      semester: (json['semester'] ?? '') as String,
      bio: (json['bio'] ?? '') as String,
      skills: List<String>.from(json['skills'] ?? []),
      portfolioUrl: (json['portfolio_url'] ?? '') as String,
      isVerified: json['is_verified'] ?? false,
      profileCompletion: (json['profile_completion'] ?? 0) as int,
    );
  }
}

class BusinessProfileResponse {
  final int id;
  final String email;
  final String? fullName;
  final String? location;
  final String? businessType;
  final String? about;
  final bool isVerified;

  BusinessProfileResponse({
    required this.id,
    required this.email,
    this.fullName,
    this.location,
    this.businessType,
    this.about,
    required this.isVerified,
  });

  /// Display name: full name if available, otherwise the part before '@' in the email.
  String get displayName {
    if (fullName != null && fullName!.isNotEmpty) return fullName!;
    return email.isNotEmpty ? email.split('@').first : email;
  }

  factory BusinessProfileResponse.fromJson(Map<String, dynamic> json) {
    return BusinessProfileResponse(
      id: json['id'] ?? 0,
      email: (json['email'] ?? '') as String,
      fullName: json['full_name'] as String?,
      location: json['location'] as String?,
      businessType: json['business_type'] as String?,
      about: json['about'] as String?,
      isVerified: json['is_verified'] ?? false,
    );
  }
}

class BusinessProject {
  final int id;
  final int gig;
  final String gigTitle;
  final int budgetNpr;
  final String deadline;
  final List<String> deliverables;
  final String businessName;
  final String studentName;
  final String studentCollege;
  final List<String> studentSkills;
  final double studentRating;
  final int verifiedProjectsCount;
  final String status;
  final String submissionLink;
  final String submissionNote;
  final String? submittedAt;
  final String? completedAt;
  final bool hasReview;
  final String createdAt;

  BusinessProject({
    required this.id,
    required this.gig,
    required this.gigTitle,
    required this.budgetNpr,
    required this.deadline,
    required this.deliverables,
    required this.businessName,
    required this.studentName,
    this.studentCollege = '',
    this.studentSkills = const [],
    this.studentRating = 0.0,
    this.verifiedProjectsCount = 0,
    required this.status,
    required this.submissionLink,
    required this.submissionNote,
    this.submittedAt,
    this.completedAt,
    required this.hasReview,
    required this.createdAt,
  });

  factory BusinessProject.fromJson(Map<String, dynamic> json) {
    return BusinessProject(
      id: json['id'] ?? 0,
      gig: json['gig'] ?? 0,
      gigTitle: (json['gig_title'] ?? '') as String,
      budgetNpr: (json['budget_npr'] ?? 0) as int,
      deadline: (json['deadline'] ?? '') as String,
      deliverables: List<String>.from(json['deliverables'] ?? []),
      businessName: (json['business_name'] ?? '') as String,
      studentName: (json['student_name'] ?? '') as String,
      studentCollege: (json['student_college'] ?? '') as String,
      studentSkills: List<String>.from(json['student_skills'] ?? []),
      studentRating: (json['student_rating'] ?? 0.0) as double,
      verifiedProjectsCount: (json['verified_projects_count'] ?? 0) as int,
      status: (json['status'] ?? '') as String,
      submissionLink: (json['submission_link'] ?? '') as String,
      submissionNote: (json['submission_note'] ?? '') as String,
      submittedAt: json['submitted_at'] as String?,
      completedAt: json['completed_at'] as String?,
      hasReview: json['has_review'] ?? false,
      createdAt: (json['created_at'] ?? '') as String,
    );
  }
}

class BusinessDashboardResponse {
  final String businessName;
  final String location;
  final bool isVerified;
  final int activeGigs;
  final int newApplicants;
  final int projectsInProgress;
  final int completedProjects;
  final List<GigApplication> recentApplications;

  BusinessDashboardResponse({
    required this.businessName,
    required this.location,
    required this.isVerified,
    required this.activeGigs,
    required this.newApplicants,
    required this.projectsInProgress,
    required this.completedProjects,
    required this.recentApplications,
  });

  factory BusinessDashboardResponse.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] ?? {};
    final recentApps = (json['recent_applications'] as List<dynamic>?)
            ?.map((a) => GigApplication.fromJson(a as Map<String, dynamic>))
            .toList() ?? [];
    return BusinessDashboardResponse(
      businessName: (json['business_name'] ?? '') as String,
      location: (json['location'] ?? '') as String,
      isVerified: json['is_verified'] ?? false,
      activeGigs: (stats['active_gigs'] ?? 0) as int,
      newApplicants: (stats['new_applicants'] ?? 0) as int,
      projectsInProgress: (stats['projects_in_progress'] ?? 0) as int,
      completedProjects: (stats['completed_projects'] ?? 0) as int,
      recentApplications: recentApps,
    );
  }
}
