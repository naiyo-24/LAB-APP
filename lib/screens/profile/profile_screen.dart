import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/side_nav_bar.dart';
import '../../providers/auth_provider.dart';
import '../../cards/profile/profile_header_card.dart';
import '../../cards/profile/profile_options_card.dart';

import '../../providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user?.id != null) {
        ref.read(profileProvider.notifier).fetchProfile(user!.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final profileState = ref.watch(profileProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'My Profile',
        subtitle: 'LABORATORY ACCOUNT',
        showDrawer: true,
      ),
      drawer: const SideNavBar(),
      body: user == null
          ? const Center(child: Text('No user data found'))
          : profileState.isLoading && profileState.user == null
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () async {
                    if (user.id != null) {
                      await ref
                          .read(profileProvider.notifier)
                          .fetchProfile(user.id!);
                    }
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        ProfileHeaderCard(user: profileState.user ?? user),
                        const SizedBox(height: 32),
                        const ProfileOptionsCard(),
                        if (profileState.error != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            profileState.error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                        const SizedBox(height: 48),
                        // App Version Info
                        Text(
                          'VERSION 1.0.0 (STABLE)',
                          style: AppTextStyles.tagline.copyWith(
                            fontSize: 10,
                            color: AppColors.textSecondary.withAlpha(150),
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
    );
  }
}
