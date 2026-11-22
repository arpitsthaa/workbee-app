import 'package:flutter/material.dart';

class PassportScreen extends StatelessWidget {
  const PassportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D61E7);
    const softBlueBg = Color(0xFFEFF6FF);
    const darkText = Color(0xFF0F172A);
    const mutedText = Color(0xFF64748B);
    const borderColor = Color(0xFFE2E8F0);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
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

                // Student Info Row
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
                      child: const Text(
                        'AS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Anisha Shrestha',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: darkText,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Patan Multiple Campus · BCA',
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

                // Summary Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: softBlueBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '2 verified projects',
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
                            '4.9/5',
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

                // Section Title
                const Text(
                  'Completed projects',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 12),

                // Project Card 1
                _VerifiedProjectCard(
                  title: 'Product Catalog Design',
                  businessAndLocation: 'Patan Crafts · Patan, Lalitpur',
                  roleAndSkills: 'Graphic designer · Canva, Layout design',
                  dateText: 'Completed 24 Sep 2026',
                  ratingText: '5.0/5',
                  feedback:
                  '"Beautiful layouts and delivered on time. Understood our products well."',
                  borderColor: borderColor,
                ),
                const SizedBox(height: 14),

                // Project Card 2
                _VerifiedProjectCard(
                  title: 'Menu Refresh',
                  businessAndLocation: 'Himalayan Beans · Jhamsikhel, Lalitpur',
                  roleAndSkills: 'Graphic designer · Figma, Typography',
                  dateText: 'Completed 4 Oct 2026',
                  ratingText: '4.8/5',
                  feedback:
                  '"A clean, readable menu our customers love. Great communication throughout."',
                  borderColor: borderColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// REUSABLE VERIFIED PROJECT CARD
// ---------------------------------------------------------------------------

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
          // Title + Verified Badge
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

          // Rating & Date Row
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

          // Client Quote
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