import 'package:flutter/material.dart';
import '../../models/about_us.dart';
import '../../theme/app_theme.dart';

class MissionVisionCard extends StatelessWidget {
  final AboutUsModel aboutUs;

  const MissionVisionCard({super.key, required this.aboutUs});

  @override
  Widget build(BuildContext context) {
    if (aboutUs.mission == null && aboutUs.vision == null) return const SizedBox.shrink();

    return Column(
      children: [
        if (aboutUs.mission != null)
          _buildCard(
            title: 'Our Mission',
            content: aboutUs.mission!,
            icon: Icons.flag_outlined,
            color: AppColors.primary,
          ),
        if (aboutUs.mission != null && aboutUs.vision != null)
          const SizedBox(height: 16),
        if (aboutUs.vision != null)
          _buildCard(
            title: 'Our Vision',
            content: aboutUs.vision!,
            icon: Icons.visibility_outlined,
            color: AppColors.secondary,
          ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.cardTitle,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: AppTextStyles.description,
          ),
        ],
      ),
    );
  }
}
