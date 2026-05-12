import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../theme/app_theme.dart';

class ProfileOptionsCard extends StatelessWidget {
  const ProfileOptionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('ACCOUNT MANAGEMENT'),
        _buildOptionsGroup(context, [
          _OptionData(
            icon: IconsaxPlusBold.edit,
            title: 'Update Profile',
            subtitle: 'Personalize your lab information',
            color: Colors.blue,
            route: '/update-profile',
          ),
          _OptionData(
            icon: IconsaxPlusBold.notification,
            title: 'Notifications',
            subtitle: 'Alerts and sound preferences',
            color: Colors.orange,
            route: '/notifications',
          ),
        ]),
        const SizedBox(height: 24),
        _buildSectionTitle('PREFERENCES & INFO'),
        _buildOptionsGroup(context, [
          _OptionData(
            icon: IconsaxPlusBold.info_circle,
            title: 'About Us',
            subtitle: 'Learn more about Medy24',
            color: Colors.green,
            route: '/about',
          ),
          _OptionData(
            icon: IconsaxPlusBold.setting_2,
            title: 'Settings',
            subtitle: 'App themes and configurations',
            color: Colors.purple,
            route: '/settings',
          ),
        ]),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: AppTextStyles.tagline.copyWith(
          fontSize: 11,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildOptionsGroup(BuildContext context, List<_OptionData> options) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(options.length, (index) {
          final option = options[index];
          return Column(
            children: [
              _buildOptionTile(context, option),
              if (index < options.length - 1)
                Divider(height: 1, color: AppColors.divider.withAlpha(100), indent: 70),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, _OptionData option) {
    return ListTile(
      onTap: () => context.push(option.route),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: option.color.withAlpha(20),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(option.icon, color: option.color, size: 22),
      ),
      title: Text(
        option.title,
        style: AppTextStyles.cardTitle.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        option.subtitle,
        style: AppTextStyles.caption.copyWith(fontSize: 13),
      ),
      trailing: Icon(
        IconsaxPlusLinear.arrow_right_3,
        size: 16,
        color: AppColors.textSecondary.withAlpha(100),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}

class _OptionData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String route;

  _OptionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.route,
  });
}
