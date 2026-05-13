import 'package:flutter/material.dart';
import '../../models/about_us.dart';
import '../../theme/app_theme.dart';

class CompanyDescriptionCard extends StatelessWidget {
  final AboutUsModel aboutUs;

  const CompanyDescriptionCard({super.key, required this.aboutUs});

  @override
  Widget build(BuildContext context) {
    if (aboutUs.companyDescriptionText == null) return const SizedBox.shrink();

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
              const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'About Company',
                style: AppTextStyles.cardTitle,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            aboutUs.companyDescriptionText!,
            style: AppTextStyles.description,
          ),
        ],
      ),
    );
  }
}
