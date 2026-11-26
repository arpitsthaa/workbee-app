import 'package:flutter/material.dart';
import 'package:workbee_frontend/clients/student_client.dart';
import 'package:workbee_frontend/constants/app_colors.dart';
import 'package:workbee_frontend/models/api_models.dart';
import 'package:workbee_frontend/services/token_service.dart';
import 'package:workbee_frontend/widgets/student_profile_header.dart';

/// Career Passport page showing verified projects and average rating.
class StudentPassportPage extends StatefulWidget {
  const StudentPassportPage({super.key});

  @override
  State<StudentPassportPage> createState() => _StudentPassportPageState();
}

class _StudentPassportPageState extends State<StudentPassportPage> {
  PassportResponse? _passport;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPassport();
  }

  Future<void> _loadPassport() async {
    final result = await StudentClient.getPassport();
    if (!mounted) return;
    if (result.containsKey('error')) {
      setState(() {
        _error = result['error'] as String?;
        _isLoading = false;
      });
    } else {
      setState(() {
        _passport = PassportResponse.fromJson(result);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error',
                style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadPassport,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StudentProfileHeader(
                displayName: TokenService.getNameSync() ?? _passport?.fullName ?? 'Student',
                collegeProgram: TokenService.getCollegeUniversitySync() ??
                    _passport?.collegeUniversity,
                isVerified: (_passport?.verifiedProjectsCount ?? 0) > 0,
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.softBlueBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_passport?.verifiedProjectsCount ?? 0} verified projects',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Completed & business-approved',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          (_passport?.averageRating ?? 0.0).toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkText,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Avg. rating',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Completed projects',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 12),
              if (_passport?.completedProjects.isEmpty ?? true)
                const Text(
                  'No verified projects yet. Complete gigs to build your passport.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.mutedText,
                  ),
                )
              else
                ...(_passport?.completedProjects ?? []).map((review) {
                  return Column(
                    children: [
                      VerifiedProjectCard(
                        title: review.gigTitle,
                        businessAndLocation:
                            '${review.businessName} · ${review.businessLocation}',
                        roleAndSkills:
                            '${review.roleTitle} · ${review.skills.join(', ')}',
                        dateText: 'Completed ${review.completedAt ?? review.createdAt}',
                        ratingText: '${review.rating.toStringAsFixed(1)}/5',
                        feedback: review.reviewComment,
                        borderColor: AppColors.borderColor,
                      ),
                      const SizedBox(height: 14),
                    ],
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

/// Verified project card widget (used only by passport page).
class VerifiedProjectCard extends StatelessWidget {
  final String title;
  final String businessAndLocation;
  final String roleAndSkills;
  final String dateText;
  final String ratingText;
  final String feedback;
  final Color borderColor;

  const VerifiedProjectCard({
    super.key,
    required this.title,
    required this.businessAndLocation,
    required this.roleAndSkills,
    required this.dateText,
    required this.ratingText,
    required this.feedback,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.softBlueBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, size: 14, color: AppColors.primaryBlue),
                    SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            businessAndLocation,
            style: const TextStyle(fontSize: 13.5, color: AppColors.mutedText),
          ),
          const SizedBox(height: 6),
          Text(
            roleAndSkills,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.labelRegister,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 18,
                    color: AppColors.beeGold,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    ratingText,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                ],
              ),
              Text(
                dateText,
                style: const TextStyle(fontSize: 12.5, color: AppColors.mutedText),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            feedback,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              fontStyle: FontStyle.italic,
              color: AppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}

