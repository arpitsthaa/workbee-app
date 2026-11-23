import 'package:flutter/material.dart';

class GigCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String payText;
  final String metaText;
  final bool highlightMeta;
  final VoidCallback onTap;

  const GigCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.payText,
    required this.metaText,
    required this.highlightMeta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D61E7);
    const mutedText = Color(0xFF64748B);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: mutedText,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  payText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: primaryBlue,
                  ),
                ),
                Text(
                  metaText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: highlightMeta ? FontWeight.w600 : FontWeight.w400,
                    color: highlightMeta ? primaryBlue : mutedText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String countText;
  final String subtitleText;
  final Color borderColor;
  final VoidCallback onTap;

  const StatCard({
    super.key,
    required this.countText,
    required this.subtitleText,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              countText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitleText,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardHeader extends StatelessWidget {
  final String studentName;
  final bool isVerified;
  final bool isLoading;

  const DashboardHeader({
    super.key,
    required this.studentName,
    required this.isVerified,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    const darkText = Color(0xFF0F172A);
    const mutedText = Color(0xFF64748B);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/workbee_logo.png',
              width: 44,
              height: 44,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WorkBee',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: darkText,
                    height: 1.1,
                  ),
                ),
                Text(
                  'Bee Busy Be Paid',
                  style: TextStyle(
                    fontSize: 12,
                    color: mutedText,
                  ),
                ),
              ],
            ),
          ],
        ),
        isLoading ? const AvatarSkeleton() : DashboardAvatar(studentName: studentName, isVerified: isVerified),
      ],
    );
  }
}

class DashboardAvatar extends StatelessWidget {
  final String studentName;
  final bool isVerified;

  const DashboardAvatar({
    super.key,
    required this.studentName,
    required this.isVerified,
  });

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D61E7);
    const softBlueBg = Color(0xFFEFF6FF);

    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: softBlueBg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        studentName.isNotEmpty ? studentName[0].toUpperCase() : 'S',
        style: const TextStyle(
          color: primaryBlue,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}

class AvatarSkeleton extends StatelessWidget {
  const AvatarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    const softBlueBg = Color(0xFFEFF6FF);

    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: softBlueBg,
        shape: BoxShape.circle,
      ),
    );
  }
}

class GreetingSkeleton extends StatelessWidget {
  const GreetingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    const softBlueBg = Color(0xFFEFF6FF);

    return Container(
      height: 32,
      width: 120,
      decoration: BoxDecoration(
        color: softBlueBg,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class VerifiedBadgeSkeleton extends StatelessWidget {
  const VerifiedBadgeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    const softBlueBg = Color(0xFFEFF6FF);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: softBlueBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: softBlueBg,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 4),
          Container(
            height: 12,
            width: 90,
            decoration: BoxDecoration(
              color: softBlueBg,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileCompletionSkeleton extends StatelessWidget {
  const ProfileCompletionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    const softBlueBg = Color(0xFFEFF6FF);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: softBlueBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 18,
            width: 140,
            decoration: BoxDecoration(
              color: softBlueBg,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 6,
              width: 200,
              decoration: BoxDecoration(
                color: softBlueBg,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 12.5,
            width: 160,
            decoration: BoxDecoration(
              color: softBlueBg,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

class GigCardSkeletons extends StatelessWidget {
  const GigCardSkeletons({super.key});

  @override
  Widget build(BuildContext context) {
    const softBlueBg = Color(0xFFEFF6FF);

    return Column(
      children: List.generate(3, (index) {
        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: softBlueBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 120,
                    decoration: BoxDecoration(
                      color: softBlueBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 13,
                    width: 200,
                    decoration: BoxDecoration(
                      color: softBlueBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 14,
                        width: 80,
                        decoration: BoxDecoration(
                          color: softBlueBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        height: 13,
                        width: 100,
                        decoration: BoxDecoration(
                          color: softBlueBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        );
      }),
    );
  }
}

class StatCardSkeletons extends StatelessWidget {
  const StatCardSkeletons({super.key});

  @override
  Widget build(BuildContext context) {
    const softBlueBg = Color(0xFFEFF6FF);

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: softBlueBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: 100,
                  decoration: BoxDecoration(
                    color: softBlueBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 12.5,
                  width: 160,
                  decoration: BoxDecoration(
                    color: softBlueBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: softBlueBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: 100,
                  decoration: BoxDecoration(
                    color: softBlueBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 12.5,
                  width: 160,
                  decoration: BoxDecoration(
                    color: softBlueBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PassportCardSkeleton extends StatelessWidget {
  const PassportCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1D61E7);
    const softBlueBg = Color(0xFFEFF6FF);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: softBlueBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryBlue, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: softBlueBg,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 15,
                      width: 100,
                      decoration: BoxDecoration(
                        color: softBlueBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      height: 16,
                      width: 20,
                      decoration: BoxDecoration(
                        color: softBlueBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  height: 12.5,
                  width: 140,
                  decoration: BoxDecoration(
                    color: softBlueBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
