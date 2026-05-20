import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../models/core_lab_test.dart';
import '../../services/api_url.dart';
import '../../theme/app_theme.dart';

class CoreLabTestBottomSheet extends StatelessWidget {
  final CoreLabTest test;

  const CoreLabTestBottomSheet({super.key, required this.test});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.borderRadius),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  children: [
                    // Header Image & Name
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: AppColors.primary.withOpacity(0.15),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                              width: 1.5,
                            ),
                            image: test.testPhotoUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(
                                      ApiUrl.imageUrl(test.testPhotoUrl!),
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: test.testPhotoUrl == null
                              ? const Icon(
                                  IconsaxPlusLinear.monitor,
                                  size: 40,
                                  color: AppColors.primary,
                                )
                              : null,
                        ),
                        const SizedBox(width: AppSpacing.cardPadding),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                test.testName,
                                style: AppTextStyles.header.copyWith(
                                  fontSize: 24,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildBadge(
                                    test.testCategory,
                                    IconsaxPlusLinear.category,
                                    AppColors.info,
                                    AppColors.info.withOpacity(0.15),
                                  ),
                                  _buildBadge(
                                    test.sampleType,
                                    IconsaxPlusLinear.drop,
                                    AppColors.error,
                                    AppColors.error.withOpacity(0.15),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),
                    // Description
                    if (test.description != null &&
                        test.description!.isNotEmpty) ...[
                      const Text("About the Test", style: AppTextStyles.cardTitle),
                      const SizedBox(height: AppSpacing.elementGap),
                      Text(
                        test.description!,
                        style: AppTextStyles.description.copyWith(
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                    ],
                    // Parameters
                    Row(
                      children: [
                        const Icon(IconsaxPlusLinear.health, color: AppColors.primary, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          "Test Parameters",
                          style: AppTextStyles.cardTitle.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.elementGap),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.cardPadding),
                      decoration: AppCardStyles.sleekCard.copyWith(
                        color: AppColors.background,
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: test.parameters.map((param) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              param,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),
                    // Precautions
                    if (test.precautions.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(IconsaxPlusLinear.shield_tick, color: AppColors.warning, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            "Precautions",
                            style: AppTextStyles.cardTitle.copyWith(color: AppColors.warning),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.elementGap),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.cardPadding),
                        decoration: AppCardStyles.sleekCard.copyWith(
                          color: AppColors.warning.withOpacity(0.05),
                          border: Border.all(color: AppColors.warning.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: test.precautions.map((precaution) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    IconsaxPlusLinear.info_circle,
                                    size: 20,
                                    color: AppColors.warning,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      precaution,
                                      style: AppTextStyles.description.copyWith(
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                    ],
                    // Spacer for scrolling
                    const SizedBox(height: 80),
                  ],
                ),
              ),
              // Pinned Bottom Button
              Container(
                padding: const EdgeInsets.only(
                  left: AppSpacing.screenPadding,
                  right: AppSpacing.screenPadding,
                  top: AppSpacing.elementGap,
                  bottom: 30, // Safety for home indicator
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.pop(); // Close bottom sheet
                      context.push('/create-test', extra: test);
                    },
                    icon: const Icon(IconsaxPlusLinear.add_square, size: 24),
                    label: const Text("Add to Inventory"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.borderRadius,
                        ),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadge(String text, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
