import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../theme/app_theme.dart';

class ContactSupportBottomSheet extends StatelessWidget {
  const ContactSupportBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.borderRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Contact Support',
            style: AppTextStyles.subHeader,
          ),
          const SizedBox(height: AppSpacing.elementGap),
          const Text(
            'How can we help you today? Our team is available 24/7 to assist you.',
            textAlign: TextAlign.center,
            style: AppTextStyles.description,
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          _buildSupportOption(
            icon: IconsaxPlusLinear.call,
            title: 'Call Us',
            subtitle: '+91 98765 43210',
            onTap: () {},
          ),
          const SizedBox(height: AppSpacing.elementGap),
          _buildSupportOption(
            icon: IconsaxPlusLinear.sms,
            title: 'Email Us',
            subtitle: 'support@medy24.com',
            onTap: () {},
          ),
          const SizedBox(height: AppSpacing.elementGap),
          _buildSupportOption(
            icon: IconsaxPlusLinear.global,
            title: 'Visit Website',
            subtitle: 'www.medy24.com',
            onTap: () {},
          ),
          const SizedBox(height: AppSpacing.sectionGap),
        ],
      ),
    );
  }

  Widget _buildSupportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryAccent),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.cardTitle.copyWith(fontSize: 16)),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            const Icon(IconsaxPlusLinear.arrow_right_3, color: AppColors.textTertiary, size: 18),
          ],
        ),
      ),
    );
  }
}
