import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../models/my_lab_test.dart';
import '../../services/api_url.dart';
import '../../theme/app_theme.dart';

class LabTestCard extends StatelessWidget {
  final MyLabTest test;

  const LabTestCard({super.key, required this.test});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.elementGap),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          onTap: () => context.push('/test-details', extra: test),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Row(
              children: [
                // Test Photo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.elementGap),
                    color: AppColors.background,
                    image: test.coreTestDetails?.testPhotoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(
                              "${ApiUrl.baseUrl}/${test.coreTestDetails!.testPhotoUrl}",
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: test.coreTestDetails?.testPhotoUrl == null
                      ? const Icon(
                          IconsaxPlusLinear.box,
                          color: AppColors.textTertiary,
                        )
                      : null,
                ),
                const SizedBox(width: AppSpacing.cardPadding),
                // Test Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        test.coreTestDetails?.testName ?? "Unknown Test",
                        style: AppTextStyles.cardTitle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        test.coreTestDetails?.testCategory ?? "No Category",
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            IconsaxPlusLinear.document_text,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${test.coreTestDetails?.parameters.length ?? 0} Parameters",
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Pricing
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "₹${test.marketPrice.toStringAsFixed(0)}",
                      style: AppTextStyles.cardTitle.copyWith(
                        color: AppColors.primaryAccent,
                      ),
                    ),
                    if (test.discountPercent > 0)
                      Text(
                        "₹${test.price.toStringAsFixed(0)}",
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
