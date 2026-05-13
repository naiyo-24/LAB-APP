import 'package:flutter/material.dart';
import '../../models/about_us.dart';
import '../../theme/app_theme.dart';
import '../../services/api_url.dart';

class PartnerCard extends StatelessWidget {
  final AboutUsModel aboutUs;

  const PartnerCard({super.key, required this.aboutUs});

  @override
  Widget build(BuildContext context) {
    if (aboutUs.partners == null || aboutUs.partners!.isEmpty) return const SizedBox.shrink();

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
              const Icon(Icons.handshake_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Our Partners',
                style: AppTextStyles.cardTitle,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: aboutUs.partners!.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final partner = aboutUs.partners![index];
                return _buildPartnerItem(partner);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerItem(dynamic partner) {
    // Assuming partner might be a simple string or a map with name/logo
    String? logoUrl;
    String? name;

    if (partner is Map) {
      logoUrl = partner['logo_url'] ?? partner['logo'];
      name = partner['name'];
    } else if (partner is String) {
      name = partner;
    }

    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: logoUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.network(
                    logoUrl.startsWith('http') ? logoUrl : ApiUrl.imageUrl(logoUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, size: 25, color: AppColors.primary),
                  ),
                )
              : const Icon(Icons.business, size: 25, color: AppColors.primary),
        ),
        if (name != null) ...[
          const SizedBox(height: 4),
          Text(
            name,
            style: AppTextStyles.caption.copyWith(fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
