import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../models/core_lab_test.dart';
import '../../services/api_url.dart';
import 'core_lab_test_bottomsheet.dart';
import '../../theme/app_theme.dart';

class CoreLabTestCard extends StatelessWidget {
  final CoreLabTest test;

  const CoreLabTestCard({super.key, required this.test});

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
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => CoreLabTestBottomSheet(test: test),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Row(
              children: [
                // Test Photo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.elementGap),
                    color: AppColors.background,
                    image: test.testPhotoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(
                              "${ApiUrl.baseUrl}/${test.testPhotoUrl}",
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: test.testPhotoUrl == null
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
                      Text(test.testName, style: AppTextStyles.cardTitle),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.infoLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          test.testCategory,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.info,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            IconsaxPlusLinear.document_text,
                            size: 16,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${test.parameters.length} Parameters",
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
