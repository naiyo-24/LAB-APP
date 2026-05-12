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
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.cardRadius,
                            ),
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
                                  size: 40,
                                  color: AppColors.textTertiary,
                                )
                              : null,
                        ),
                        const SizedBox(width: AppSpacing.elementGap),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                test.testName,
                                style: AppTextStyles.subHeader.copyWith(
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.infoLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  test.testCategory,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.info,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(
                                    IconsaxPlusLinear.tag,
                                    size: 18,
                                    color: AppColors.textTertiary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    test.sampleType,
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
                    const SizedBox(height: AppSpacing.sectionGap),
                    // Description
                    if (test.description != null &&
                        test.description!.isNotEmpty) ...[
                      const Text("Description", style: AppTextStyles.cardTitle),
                      const SizedBox(height: AppSpacing.elementGap),
                      Text(test.description!, style: AppTextStyles.description),
                      const SizedBox(height: AppSpacing.sectionGap),
                    ],
                    // Parameters
                    const Text(
                      "Test Parameters",
                      style: AppTextStyles.cardTitle,
                    ),
                    const SizedBox(height: AppSpacing.elementGap),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: test.parameters.map((param) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Text(
                            param,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),
                    // Precautions
                    if (test.precautions.isNotEmpty) ...[
                      const Text("Precautions", style: AppTextStyles.cardTitle),
                      const SizedBox(height: AppSpacing.elementGap),
                      Column(
                        children: test.precautions.map((precaution) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  IconsaxPlusLinear.info_circle,
                                  size: 18,
                                  color: AppColors.warning,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    precaution,
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                    ],
                    // Add to Inventory Button
                    ElevatedButton(
                      onPressed: () {
                        context.pop(); // Close bottom sheet
                        context.push('/create-test', extra: test);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAccent,
                        foregroundColor: AppColors.textOnPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.borderRadius,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(IconsaxPlusLinear.add_square),
                          SizedBox(width: 12),
                          Text(
                            "Add to Inventory",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
