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
      rating: (json['rating'] ?? 0.0) as double,
      reviewComment: (json['review_comment'] ?? '') as String,
      submissionLink: json['submission_link'] as String?,
      completedAt: json['completed_at'] as String?,
      createdAt: (json['created_at'] ?? '') as String,
    );
  }
}

class DashboardResponse {
  final String fullName;
  final bool isVerified;
  final int profileCompletion;
  final List<Gig> recommendedGigs;
  final Map<String, dynamic> applicationsSummary;
  final Map<String, dynamic> projectsSummary;
  final Map<String, dynamic> careerPassport;

  DashboardResponse({
    required this.fullName,
    required this.isVerified,
    required this.profileCompletion,
    required this.recommendedGigs,
    required this.applicationsSummary,
    required this.projectsSummary,
    required this.careerPassport,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      fullName: (json['full_name'] ?? 'Student') as String,
      isVerified: json['is_verified'] ?? false,
      profileCompletion: (json['profile_completion'] ?? 0) as int,
      recommendedGigs: (json['recommended_gigs'] as List<dynamic>?)
              ?.map((g) => Gig.fromJson(g as Map<String, dynamic>))
              .toList() ?? [],
      applicationsSummary: (json['applications_summary'] ?? {}) as Map<String, dynamic>,
      projectsSummary: (json['projects_summary'] ?? {}) as Map<String, dynamic>,
      careerPassport: (json['career_passport'] ?? {}) as Map<String, dynamic>,
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
      averageRating: (json['average_rating'] ?? 0.0) as double,
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

class WorkResponse {
  final List<GigApplication> applications;
  final List<Project> projects;

  WorkResponse({
    required this.applications,
    required this.projects,
  });

  factory WorkResponse.fromJson(Map<String, dynamic> json) {
    return WorkResponse(
      applications: (json['applications'] as List<dynamic>?)
              ?.map((a) => GigApplication.fromJson(a as Map<String, dynamic>))
              .toList() ?? [],
      projects: (json['projects'] as List<dynamic>?)
              ?.map((p) => Project.fromJson(p as Map<String, dynamic>))
              .toList() ?? [],
    );
  }
}
