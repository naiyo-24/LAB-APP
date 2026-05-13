import 'package:flutter/material.dart';
import '../../models/about_us.dart';
import '../../theme/app_theme.dart';

class ContactCard extends StatelessWidget {
  final AboutUsModel aboutUs;

  const ContactCard({super.key, required this.aboutUs});

  @override
  Widget build(BuildContext context) {
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
              const Icon(Icons.contact_support_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Contact Information',
                style: AppTextStyles.cardTitle,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (aboutUs.officeAddress != null)
            _buildContactItem(
              icon: Icons.location_on_outlined,
              label: 'Office Address',
              value: aboutUs.officeAddress!,
            ),
          if (aboutUs.email1 != null)
            _buildContactItem(
              icon: Icons.email_outlined,
              label: 'Email',
              value: aboutUs.email1!,
              value2: aboutUs.email2,
            ),
          if (aboutUs.phone1 != null)
            _buildContactItem(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: aboutUs.phone1!,
              value2: aboutUs.phone2,
            ),
          if (aboutUs.website != null)
            _buildContactItem(
              icon: Icons.language_outlined,
              label: 'Website',
              value: aboutUs.website!,
            ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    String? value2,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  value,
                  style: AppTextStyles.description.copyWith(fontSize: 14),
                ),
                if (value2 != null)
                  Text(
                    value2,
                    style: AppTextStyles.description.copyWith(fontSize: 14),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
