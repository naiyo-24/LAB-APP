import 'package:flutter/material.dart';
import '../../models/about_us.dart';
import '../../theme/app_theme.dart';
import '../../services/api_url.dart';

class DirectorMessageCard extends StatelessWidget {
  final AboutUsModel aboutUs;

  const DirectorMessageCard({super.key, required this.aboutUs});

  @override
  Widget build(BuildContext context) {
    if (aboutUs.directorMessage == null) return const SizedBox.shrink();

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
              const Icon(Icons.format_quote, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Director\'s Message',
                style: AppTextStyles.cardTitle,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (aboutUs.directorPhoto != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    ApiUrl.imageUrl(aboutUs.directorPhoto!),
                    width: 80,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80,
                      height: 100,
                      color: AppColors.primary.withAlpha(50),
                      child: const Icon(Icons.person, size: 40, color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aboutUs.directorMessage!,
                      style: AppTextStyles.description.copyWith(fontStyle: FontStyle.italic),
                    ),
                    if (aboutUs.directorName != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        '- ${aboutUs.directorName}',
                        style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
