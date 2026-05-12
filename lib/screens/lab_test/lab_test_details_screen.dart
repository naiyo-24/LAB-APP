import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../models/my_lab_test.dart';
import '../../services/api_url.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../providers/lab_test_provider.dart';

class LabTestDetailsScreen extends ConsumerWidget {
  final MyLabTest test;

  const LabTestDetailsScreen({super.key, required this.test});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: "Test Details",
        subtitle: test.coreTestDetails?.testName ?? "Test Info",
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement edit logic
            },
            icon: const Icon(IconsaxPlusLinear.edit, color: AppColors.textPrimary),
          ),
          IconButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Delete Test"),
                  content: const Text("Are you sure you want to remove this test from your inventory?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: AppColors.error))),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(myLabTestProvider.notifier).deleteFromInventory(test.testId);
                if (context.mounted) Navigator.pop(context);
              }
            },
            icon: const Icon(IconsaxPlusLinear.trash, color: AppColors.error),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo & Identity
            _buildHeader(),
            const SizedBox(height: AppSpacing.sectionGap),

            // Times
            _buildSectionTitle("Logistics"),
            _buildDetailRow(IconsaxPlusLinear.clock, "Sample Collection", test.sampleCollectionTime),
            _buildDetailRow(IconsaxPlusLinear.timer_1, "Report Delivery", test.reportDeliveryTime),
            const SizedBox(height: AppSpacing.sectionGap),

            // Pricing
            _buildSectionTitle("Pricing"),
            _buildDetailRow(IconsaxPlusLinear.money, "Base Price", "₹${test.price.toStringAsFixed(2)}"),
            _buildDetailRow(IconsaxPlusLinear.percentage_square, "Discount", "${test.discountPercent}%"),
            _buildDetailRow(IconsaxPlusLinear.wallet, "Market Price", "₹${test.marketPrice.toStringAsFixed(2)}", isHighlight: true),
            const SizedBox(height: AppSpacing.sectionGap),

            // Core Details
            if (test.coreTestDetails?.description != null) ...[
              _buildSectionTitle("Description"),
              Text(test.coreTestDetails!.description!, style: AppTextStyles.description),
              const SizedBox(height: AppSpacing.sectionGap),
            ],

            // Parameters
            if (test.coreTestDetails?.parameters.isNotEmpty ?? false) ...[
              _buildSectionTitle("Parameters Included"),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: test.coreTestDetails!.parameters.map((p) => _buildChip(p)).toList(),
              ),
              const SizedBox(height: AppSpacing.sectionGap),
            ],

            // Precautions
            if (test.coreTestDetails?.precautions.isNotEmpty ?? false) ...[
              _buildSectionTitle("Precautions"),
              ...test.coreTestDetails!.precautions.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(IconsaxPlusLinear.info_circle, size: 18, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Expanded(child: Text(p, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary))),
                  ],
                ),
              )),
              const SizedBox(height: AppSpacing.sectionGap),
            ],

            // Reviews
            _buildSectionTitle("Reviews"),
            if (test.reviews.isEmpty)
              const Text("No reviews yet", style: AppTextStyles.caption)
            else
              const Text("Review section coming soon..."),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: AppCardStyles.sleekCard,
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              color: AppColors.background,
              image: test.coreTestDetails?.testPhotoUrl != null
                  ? DecorationImage(
                      image: NetworkImage("${ApiUrl.baseUrl}/${test.coreTestDetails!.testPhotoUrl}"),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: test.coreTestDetails?.testPhotoUrl == null ? const Icon(IconsaxPlusLinear.box, size: 40, color: AppColors.textTertiary) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(test.coreTestDetails?.testName ?? "Unknown", style: AppTextStyles.cardTitle),
                Text(test.coreTestDetails?.testCategory ?? "No Category", style: AppTextStyles.caption),
                const SizedBox(height: 8),
                Text("Test ID: ${test.testId}", style: AppTextStyles.caption.copyWith(fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: AppTextStyles.subHeader.copyWith(fontSize: 18)),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: isHighlight ? AppColors.primaryAccent : AppColors.textTertiary),
          const SizedBox(width: 12),
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.cardTitle.copyWith(
              fontSize: 16,
              color: isHighlight ? AppColors.primaryAccent : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary)),
    );
  }
}
