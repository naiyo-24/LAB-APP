import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../models/my_lab_test.dart';
import '../../services/api_url.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../providers/lab_test_provider.dart';

class LabTestDetailsScreen extends ConsumerStatefulWidget {
  final MyLabTest test;

  const LabTestDetailsScreen({super.key, required this.test});

  @override
  ConsumerState<LabTestDetailsScreen> createState() =>
      _LabTestDetailsScreenState();
}

class _LabTestDetailsScreenState extends ConsumerState<LabTestDetailsScreen> {
  bool _isEditing = false;
  late TextEditingController _priceController;
  late TextEditingController _discountController;
  String? _selectedSampleTime;
  String? _selectedReportTime;

  final List<String> _timeOptions = [
    "Within 2 hours",
    "4 hours",
    "10 hours",
    "24 hours",
    "2 days",
    "4 days",
    "7 days",
  ];

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.test.price.toString(),
    );
    _discountController = TextEditingController(
      text: widget.test.discountPercent.toString(),
    );
    _selectedSampleTime = widget.test.sampleCollectionTime;
    _selectedReportTime = widget.test.reportDeliveryTime;
  }

  @override
  void dispose() {
    _priceController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final data = {
      'sample_collection_time': _selectedSampleTime,
      'report_delivery_time': _selectedReportTime,
      'price': double.tryParse(_priceController.text) ?? widget.test.price,
      'discount_percent':
          double.tryParse(_discountController.text) ??
          widget.test.discountPercent,
    };

    await ref
        .read(myLabTestProvider.notifier)
        .updateInventory(widget.test.testId, data);

    setState(() {
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Test updated successfully")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch for updates to the test object
    final tests = ref.watch(myLabTestProvider).value ?? [];
    final currentTest = tests.firstWhere(
      (t) => t.testId == widget.test.testId,
      orElse: () => widget.test,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: _isEditing ? "Edit Test" : "Test Details",
        subtitle: currentTest.coreTestDetails?.testName ?? "Test Info",
        actions: [
          if (!_isEditing) ...[
            IconButton(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(
                IconsaxPlusLinear.edit,
                color: AppColors.textPrimary,
              ),
            ),
            IconButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Delete Test"),
                    content: const Text(
                      "Are you sure you want to remove this test from your inventory?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          "Delete",
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref
                      .read(myLabTestProvider.notifier)
                      .deleteFromInventory(currentTest.testId);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              icon: const Icon(IconsaxPlusLinear.trash, color: AppColors.error),
            ),
          ] else ...[
            IconButton(
              onPressed: _handleSave,
              icon: const Icon(
                IconsaxPlusLinear.tick_circle,
                color: AppColors.success,
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _isEditing = false),
              icon: const Icon(
                IconsaxPlusLinear.close_circle,
                color: AppColors.error,
              ),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo & Identity
            _buildHeader(currentTest),
            const SizedBox(height: AppSpacing.sectionGap),

            // Times
            _buildSectionTitle("Logistics"),
            if (_isEditing) ...[
              _buildDropdownField(
                label: "Sample Collection Time",
                value: _selectedSampleTime,
                items: _timeOptions,
                onChanged: (val) => setState(() => _selectedSampleTime = val),
              ),
              const SizedBox(height: AppSpacing.elementGap),
              _buildDropdownField(
                label: "Report Delivery Time",
                value: _selectedReportTime,
                items: _timeOptions,
                onChanged: (val) => setState(() => _selectedReportTime = val),
              ),
            ] else ...[
              _buildDetailRow(
                IconsaxPlusLinear.clock,
                "Sample Collection",
                currentTest.sampleCollectionTime,
              ),
              _buildDetailRow(
                IconsaxPlusLinear.timer_1,
                "Report Delivery",
                currentTest.reportDeliveryTime,
              ),
            ],
            const SizedBox(height: AppSpacing.sectionGap),

            // Pricing
            _buildSectionTitle("Pricing"),
            if (_isEditing) ...[
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Price",
                  prefixText: "₹ ",
                ),
              ),
              const SizedBox(height: AppSpacing.elementGap),
              TextFormField(
                controller: _discountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Discount Percent",
                  suffixText: "%",
                ),
              ),
            ] else ...[
              _buildDetailRow(
                IconsaxPlusLinear.money,
                "Base Price",
                "₹${currentTest.price.toStringAsFixed(2)}",
              ),
              _buildDetailRow(
                IconsaxPlusLinear.percentage_square,
                "Discount",
                "${currentTest.discountPercent}%",
              ),
              _buildDetailRow(
                IconsaxPlusLinear.wallet,
                "Market Price",
                "₹${currentTest.marketPrice.toStringAsFixed(2)}",
                isHighlight: true,
              ),
            ],
            const SizedBox(height: AppSpacing.sectionGap),

            // Core Details
            if (currentTest.coreTestDetails?.description != null) ...[
              _buildSectionTitle("Description"),
              Text(
                currentTest.coreTestDetails!.description!,
                style: AppTextStyles.description,
              ),
              const SizedBox(height: AppSpacing.sectionGap),
            ],

            // Parameters
            if (currentTest.coreTestDetails?.parameters.isNotEmpty ??
                false) ...[
              _buildSectionTitle("Parameters Included"),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: currentTest.coreTestDetails!.parameters
                    .map((p) => _buildChip(p))
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.sectionGap),
            ],

            // Precautions
            if (currentTest.coreTestDetails?.precautions.isNotEmpty ??
                false) ...[
              _buildSectionTitle("Precautions"),
              ...currentTest.coreTestDetails!.precautions.map(
                (p) => Padding(
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
                          p,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sectionGap),
            ],

            // Reviews
            _buildSectionTitle("Reviews"),
            if (currentTest.reviews.isEmpty)
              const Text("No reviews yet", style: AppTextStyles.caption)
            else
              const Text("Review section coming soon..."),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(MyLabTest test) {
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
                    size: 40,
                    color: AppColors.textTertiary,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  test.coreTestDetails?.testName ?? "Unknown",
                  style: AppTextStyles.cardTitle,
                ),
                Text(
                  test.coreTestDetails?.testCategory ?? "No Category",
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 8),
                Text(
                  "Test ID: ${test.testId}",
                  style: AppTextStyles.caption.copyWith(fontSize: 10),
                ),
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

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isHighlight
                ? AppColors.primaryAccent
                : AppColors.textTertiary,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.cardTitle.copyWith(
              fontSize: 16,
              color: isHighlight
                  ? AppColors.primaryAccent
                  : AppColors.textPrimary,
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
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    // Ensure the current value exists in items to avoid assertion errors
    final effectiveValue = items.contains(value) ? value : null;

    return DropdownButtonFormField<String>(
      initialValue: effectiveValue,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(IconsaxPlusLinear.clock, size: 20),
      ),
      items: items.map((String time) {
        return DropdownMenuItem<String>(value: time, child: Text(time));
      }).toList(),
      onChanged: onChanged,
      icon: const Icon(IconsaxPlusLinear.arrow_down_1, size: 18),
      dropdownColor: AppColors.surface,
      style: AppTextStyles.description.copyWith(color: AppColors.textPrimary),
    );
  }
}
