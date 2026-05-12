import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showDrawer;
  final bool showBackButton;
  final List<Widget>? actions;
  final VoidCallback? onBackPress;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showDrawer = false,
    this.showBackButton = true,
    this.actions,
    this.onBackPress,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 2,
      centerTitle: false,
      leading: _buildLeading(context),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTextStyles.subHeader.copyWith(fontSize: 20, height: 1.2),
          ),
          if (subtitle != null)
            Text(
              subtitle!.toUpperCase(),
              style: AppTextStyles.tagline.copyWith(
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
        ],
      ),
      actions: [if (actions != null) ...actions!, const SizedBox(width: 8)],
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (showDrawer) {
      return IconButton(
        onPressed: () => Scaffold.of(context).openDrawer(),
        icon: const Icon(IconsaxPlusLinear.menu, color: AppColors.textPrimary),
      );
    }

    if (showBackButton) {
      return IconButton(
        onPressed: onBackPress ??
            () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/dashboard'); // Fallback to dashboard if cannot pop
              }
            },
        icon: const Icon(
          IconsaxPlusLinear.arrow_left_1,
          color: AppColors.textPrimary,
        ),
      );
    }

    return null;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 5);
}
