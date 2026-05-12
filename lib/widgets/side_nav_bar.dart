import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';

class SideNavBar extends ConsumerWidget {
  const SideNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final String currentRoute = GoRouterState.of(context).uri.path;

    return Drawer(
      backgroundColor: AppColors.background,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(AppSpacing.borderRadius),
          bottomRight: Radius.circular(AppSpacing.borderRadius),
        ),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(user),

          const SizedBox(height: 12),

          // Nav Items
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  _buildNavItem(
                    context,
                    icon: IconsaxPlusLinear.category,
                    label: 'Dashboard',
                    route: '/dashboard',
                    currentRoute: currentRoute,
                  ),
                  _buildNavItem(
                    context,
                    icon: IconsaxPlusLinear.box,
                    label: 'Test Inventory',
                    route: '/inventory',
                    currentRoute: currentRoute,
                  ),
                  _buildNavItem(
                    context,
                    icon: IconsaxPlusLinear.archive_add,
                    label: 'Package Inventory',
                    route: '/packages',
                    currentRoute: currentRoute,
                  ),
                  _buildNavItem(
                    context,
                    icon: IconsaxPlusLinear.document_text,
                    label: 'Available Tests',
                    route: '/test-management',
                    currentRoute: currentRoute,
                  ),
                  _buildNavItem(
                    context,
                    icon: IconsaxPlusLinear.calendar_tick,
                    label: 'Orders & Bookings',
                    route: '/bookings',
                    currentRoute: currentRoute,
                  ),
                  _buildNavItem(
                    context,
                    icon: IconsaxPlusLinear.card_receive,
                    label: 'Earning & Payments',
                    route: '/earnings',
                    currentRoute: currentRoute,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: AppColors.divider),
                  ),
                  _buildNavItem(
                    context,
                    icon: IconsaxPlusLinear.user,
                    label: 'Profile',
                    route: '/profile',
                    currentRoute: currentRoute,
                  ),
                  _buildNavItem(
                    context,
                    icon: IconsaxPlusLinear.setting_2,
                    label: 'Settings',
                    route: '/settings',
                    currentRoute: currentRoute,
                  ),
                ],
              ),
            ),
          ),

          // Logout
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildNavItem(
              context,
              icon: IconsaxPlusLinear.logout,
              label: 'Logout',
              route: '/logout',
              currentRoute: currentRoute,
              isLogout: true,
              onTap: () {
                ref.read(authProvider.notifier).logout();
                context.go('/login');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(dynamic user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 24, left: 24, right: 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(AppSpacing.borderRadius),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primary.withAlpha(50),
            child: Text(
              user?.labName?.substring(0, 1).toUpperCase() ?? 'L',
              style: AppTextStyles.header.copyWith(
                fontSize: 24,
                color: AppColors.primaryAccent,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.labName ?? 'Laboratory Partner',
            style: AppTextStyles.cardTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            user?.email ?? 'partner@medy24.com',
            style: AppTextStyles.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    required String currentRoute,
    bool isLogout = false,
    VoidCallback? onTap,
  }) {
    final bool isActive = currentRoute == route;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap ?? () => context.go(route),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withAlpha(25)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive
                    ? AppColors.primaryAccent
                    : (isLogout ? AppColors.error : AppColors.textSecondary),
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 15,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive
                        ? AppColors.primaryAccent
                        : (isLogout ? AppColors.error : AppColors.textPrimary),
                  ),
                ),
              ),
              if (isActive)
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryAccent,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
