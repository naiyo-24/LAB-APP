import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../cards/auth/error_bottomsheet.dart';
import '../../cards/auth/contact_support_bottomsheet.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage == 0) {
      if (_emailController.text.isNotEmpty) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.fastOutSlowIn,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your email')),
        );
      }
    } else {
      _handleLogin();
    }
  }

  Future<void> _handleLogin() async {
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your password')),
      );
      return;
    }

    await ref
        .read(authProvider.notifier)
        .login(_emailController.text, _passwordController.text);

    final authState = ref.read(authProvider);
    if (authState.user != null) {
      // ignore: use_build_context_synchronously
      context.go('/profile');
    } else if (authState.error != null) {
      // ignore: use_build_context_synchronously
      showModalBottomSheet(
        // ignore: use_build_context_synchronously
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ErrorBottomSheet(
          title: 'Login Failed',
          message: authState.error!,
          onContactSupport: _showSupport,
        ),
      );
    }
  }

  void _showSupport() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ContactSupportBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Decorative Elements
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withAlpha(20),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryAccent.withAlpha(15),
              ),
            ),
          ),
          
          SafeArea(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: [_buildEmailSlide(), _buildPasswordSlide()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailSlide() {
    final authState = ref.watch(authProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          Hero(
            tag: 'app_logo',
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(100),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(IconsaxPlusBold.health, size: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 40),
          const Text('Welcome Back', style: AppTextStyles.header),
          const SizedBox(height: 8),
          Text(
            'Log in to manage your pathology lab inventory.',
            style: AppTextStyles.description.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
          const Text(
            'REGISTERED EMAIL',
            style: AppTextStyles.tagline,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: AppTextStyles.description.copyWith(fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'name@lab.com',
              hintStyle: AppTextStyles.description.copyWith(color: AppColors.textTertiary),
              prefixIcon: const Icon(
                IconsaxPlusLinear.sms,
                color: AppColors.primary,
                size: 22,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 20),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: authState.isLoading ? null : _nextPage,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: authState.isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Next Step', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        const Icon(IconsaxPlusLinear.arrow_right_1, size: 20),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.description.copyWith(fontSize: 15),
                children: [
                  const TextSpan(text: "Don't have an account? ", style: TextStyle(color: AppColors.textSecondary)),
                  TextSpan(
                    text: 'Join Us',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => context.go('/signup'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPasswordSlide() {
    final authState = ref.watch(authProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          IconButton(
            onPressed: () => _pageController.previousPage(
              duration: const Duration(milliseconds: 600),
              curve: Curves.fastOutSlowIn,
            ),
            icon: const Icon(IconsaxPlusLinear.arrow_left, color: AppColors.textPrimary),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surface,
              padding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 40),
          const Text('Security Check', style: AppTextStyles.header),
          const SizedBox(height: 8),
          Text(
            'Secure your access with your lab credentials.',
            style: AppTextStyles.description.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
          const Text('PASSWORD', style: AppTextStyles.tagline),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            obscureText: true,
            style: AppTextStyles.description.copyWith(fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: AppTextStyles.description.copyWith(color: AppColors.textTertiary),
              prefixIcon: const Icon(
                IconsaxPlusLinear.lock,
                color: AppColors.primary,
                size: 22,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 20),
            ),
          ),
          const SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: authState.isLoading ? null : _nextPage,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: authState.isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Verify & Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.description.copyWith(fontSize: 15),
                children: [
                  const TextSpan(text: "Having trouble? ", style: TextStyle(color: AppColors.textSecondary)),
                  TextSpan(
                    text: 'Contact Support',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = _showSupport,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
