import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/update_profile_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bar.dart';
import '../widgets/side_nav_bar.dart';
import '../screens/lab_test/core_lab_test_list_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // Main App Routes
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const PlaceholderScreen(
          title: 'Dashboard',
          subtitle: 'Overview of your lab',
        ),
      ),
      GoRoute(
        path: '/inventory',
        builder: (context, state) => const PlaceholderScreen(
          title: 'Test Inventory',
          subtitle: 'Manage your tests',
        ),
      ),
      GoRoute(
        path: '/test-management',
        builder: (context, state) => const CoreLabTestListScreen(),
      ),
      GoRoute(
        path: '/bookings',
        builder: (context, state) => const PlaceholderScreen(
          title: 'Test Bookings',
          subtitle: 'Recent appointments',
        ),
      ),
      GoRoute(
        path: '/earnings',
        builder: (context, state) => const PlaceholderScreen(
          title: 'Earning and Payments',
          subtitle: 'Financial summary',
        ),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/update-profile',
        builder: (context, state) => const UpdateProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const PlaceholderScreen(
          title: 'Settings',
          subtitle: 'App preferences',
        ),
      ),
    ],
  );
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String? subtitle;
  const PlaceholderScreen({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: title,
        subtitle: subtitle,
        showDrawer: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              IconsaxPlusLinear.notification,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      drawer: const SideNavBar(),
      body: Center(child: Text('$title Screen')),
    );
  }
}
