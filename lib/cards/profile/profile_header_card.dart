import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../theme/app_theme.dart';
import '../../services/api_url.dart';
import '../../models/user.dart';

class ProfileHeaderCard extends StatelessWidget {
  final User user;

  const ProfileHeaderCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    ImageProvider? getImage() {
      if (user.labLogo == null) return null;
      if (user.labLogo!.startsWith('http')) {
        return NetworkImage(user.labLogo!);
      }
      if (user.labLogo!.startsWith('uploads/')) {
        return NetworkImage('${ApiUrl.baseUrl}/${user.labLogo!}');
      }
      return FileImage(File(user.labLogo!));
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkCyan,
            AppColors.primary.withAlpha(200),
            AppColors.darkCyan.withAlpha(180),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pattern (Subtle)
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              IconsaxPlusLinear.hospital,
              size: 150,
              color: Colors.white.withAlpha(20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Avatar with premium border
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.background,
                    backgroundImage: getImage(),
                    child: user.labLogo == null
                        ? const Icon(
                            IconsaxPlusLinear.hospital,
                            size: 36,
                            color: AppColors.primaryAccent,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  user.labName ?? 'Lab Name',
                  style: AppTextStyles.header.copyWith(
                    fontSize: 24,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  user.email ?? 'email@example.com',
                  style: AppTextStyles.description.copyWith(
                    color: Colors.white.withAlpha(200),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Contact Badge (Glassmorphic)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withAlpha(60)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        IconsaxPlusBold.call,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        user.mobileNumber ?? 'No Phone',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
