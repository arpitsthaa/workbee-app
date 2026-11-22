import 'package:flutter/material.dart';
import 'package:workbee_frontend/services/auth_service.dart';
import 'package:workbee_frontend/models/api_models.dart';

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
        _passport = PassportResponse.fromJson(result as Map<String, dynamic>);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D61E7);
    const softBlueBg = Color(0xFFEFF6FF);
    const darkText = Color(0xFF0F172A);
    const mutedText = Color(0xFF64748B);
    const borderColor = Color(0xFFE2E8F0);

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

    final fullName = _passport?.fullName ?? 'Student';
    final collegeUniversity = _passport?.collegeUniversity ?? '';
    final program = _passport?.program ?? '';
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
                  const Text(
                    'Career Passport',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Your work. Your verified experience.',
                    style: TextStyle(
                      fontSize: 14,
                      color: mutedText,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          color: softBlueBg,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          fullName.isNotEmpty ? fullName[0].toUpperCase() : 'A',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: primaryBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: darkText,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '$collegeUniversity · $program',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: mutedText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: softBlueBg,
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
                                color: primaryBlue,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Completed & business-approved',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: mutedText,
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
                                color: darkText,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Avg. rating',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: mutedText,
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
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (completedProjects.isEmpty)
                    const Text(
                      'No verified projects yet. Complete gigs to build your passport.',
                      style: TextStyle(
                        fontSize: 14,
                        color: mutedText,
                      ),
                    )
                  else
                    ...completedProjects.map((review) {
                      return Column(
                        children: [
                          _VerifiedProjectCard(
                            title: review.gigTitle,
                            businessAndLocation:
                                '${review.businessName} · ${review.businessLocation}',
                            roleAndSkills:
                                '${review.roleTitle} · ${review.skills.join(', ')}',
                            dateText: 'Completed ${review.completedAt ?? review.createdAt}',
                            ratingText: '${review.rating.toStringAsFixed(1)}/5',
                            feedback: review.reviewComment,
                            borderColor: borderColor,
                          ),
                          const SizedBox(height: 14),
                        ],
                      );
                    }).toList(),
                ],
              ),
            ),
          ),
        );
  }
}

class _VerifiedProjectCard extends StatelessWidget {
  final String title;
  final String businessAndLocation;
  final String roleAndSkills;
  final String dateText;
  final String ratingText;
  final String feedback;
  final Color borderColor;

  const _VerifiedProjectCard({
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
    const primaryBlue = Color(0xFF1D61E7);
    const softBlueBg = Color(0xFFEFF6FF);
    const darkText = Color(0xFF0F172A);
    const mutedText = Color(0xFF64748B);

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
                    color: darkText,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: softBlueBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, size: 14, color: primaryBlue),
                    SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: primaryBlue,
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
            style: const TextStyle(fontSize: 13.5, color: mutedText),
          ),
          const SizedBox(height: 6),
          Text(
            roleAndSkills,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
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
                    color: Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    ratingText,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: darkText,
                    ),
                  ),
                ],
              ),
              Text(
                dateText,
                style: const TextStyle(fontSize: 12.5, color: mutedText),
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
              color: mutedText,
            ),
          ),
        ],
      ),
    );
  }
}
