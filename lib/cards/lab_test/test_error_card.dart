import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../theme/app_theme.dart';

class TestErrorCard extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;

  const TestErrorCard({
    super.key,
    required this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              IconsaxPlusBold.danger,
              color: AppColors.error,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          // Error Title
          Text(
            "Inventory Conflict",
            style: AppTextStyles.subHeader.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // Error Message
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: AppTextStyles.description.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.divider),
                  ),
                  child: const Text("Go Back"),
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onRetry!();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAccent,
                    ),
                    child: const Text("Retry"),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  static void show(BuildContext context, String message, {VoidCallback? onRetry}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: TestErrorCard(
          errorMessage: message,
          onRetry: onRetry,
        ),
      ),
    );
  }
}
