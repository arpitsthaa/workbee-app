import 'package:flutter/material.dart';
import 'package:workbee_frontend/constants/app_colors.dart';
import 'package:workbee_frontend/services/auth_service.dart';
import 'package:workbee_frontend/services/user_session_service.dart';
import 'package:workbee_frontend/models/api_models.dart';
import 'package:workbee_frontend/widgets/verified_project_card.dart';
import 'package:workbee_frontend/widgets/student_profile_header.dart';

class PassportScreen extends StatefulWidget {
  const PassportScreen({super.key});

  @override
  State<PassportScreen> createState() => _PassportScreenState();
}

class _PassportScreenState extends State<PassportScreen> {
  final AuthService _authService = AuthService();

  PassportResponse? _passport;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPassport();
  }

  Future<void> _loadPassport() async {
    final result = await _authService.getCareerPassport();
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

    return ListenableBuilder(
      listenable: UserSessionService(),
      builder: (context, _) {
        final fullName = UserSessionService().userName ?? _passport?.fullName ?? 'Student';
        final collegeUniversity = UserSessionService().collegeUniversity ?? _passport?.collegeUniversity ?? '';
        final verifiedProjects = _passport?.verifiedProjectsCount ?? 0;
        final avgRating = _passport?.averageRating ?? 0.0;
        final completedProjects = _passport?.completedProjects ?? [];

        return SafeArea(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StudentProfileHeader(
                        displayName: fullName,
                        collegeProgram:
                            collegeUniversity.isNotEmpty
                                ? collegeUniversity
                                : null,
                        isVerified: verifiedProjects > 0,
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
                                  '$verifiedProjects verified projects',
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
                                  avgRating.toStringAsFixed(1),
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
                      if (completedProjects.isEmpty)
                        const Text(
                          'No verified projects yet. Complete gigs to build your passport.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.mutedText,
                          ),
                        )
                      else
                        ...completedProjects.map((review) {
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
      },
    );
  }
}
