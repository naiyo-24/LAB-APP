import 'package:flutter/material.dart';
import '../../models/core_lab_test.dart';
import '../../theme/app_theme.dart';
import 'core_lab_test_bottomsheet.dart';
import '../../services/api_url.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class SearchLabTestCard extends StatelessWidget {
  final CoreLabTest test;

  const SearchLabTestCard({super.key, required this.test});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => CoreLabTestBottomSheet(test: test),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.elementGap),
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: AppCardStyles.sleekCard,
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(51), // 0.2 * 255 = 51
                borderRadius: BorderRadius.circular(12),
              ),
              child: test.testPhotoUrl != null && test.testPhotoUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        ApiUrl.imageUrl(test.testPhotoUrl!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(child: Icon(IconsaxPlusLinear.health, color: AppColors.primary)),
                      ),
                    )
                  : const Center(
                      child: Icon(IconsaxPlusLinear.health, color: AppColors.primary, size: 24),
                    ),
            ),
            const SizedBox(width: AppSpacing.elementGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    test.testName,
                    style: AppTextStyles.cardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    test.testCategory,
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              IconsaxPlusLinear.arrow_right_3,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
