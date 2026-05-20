import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../theme/app_theme.dart';

class ErrorBottomSheet extends StatelessWidget {
  final String title;
  final String message;
  final String? statusCode;
  final VoidCallback? onContactSupport;

  const ErrorBottomSheet({
    super.key,
    required this.title,
    required this.message,
    this.statusCode,
    this.onContactSupport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.screenPadding,
            right: AppSpacing.screenPadding,
            top: AppSpacing.screenPadding,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.screenPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(IconsaxPlusLinear.close_circle),
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              // Error Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  IconsaxPlusBold.warning_2,
                  color: AppColors.error,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                title,
                style: AppTextStyles.header.copyWith(
                  color: AppColors.error,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Error Message
              Text(
                message,
                style: AppTextStyles.description.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),

              // Status Code (if available)
              if (statusCode != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Text(
                    'Error Code: $statusCode',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                      fontFamily: 'Courier',
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Okay'),
                ),
              ),
              const SizedBox(height: 12),

              // Contact Support Button (if callback provided)
              if (onContactSupport != null)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onContactSupport?.call();
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: const BorderSide(color: AppColors.primary),
                    ),
                    child: const Text(
                      'Contact Support',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
