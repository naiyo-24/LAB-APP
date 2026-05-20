import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:lab_app/services/api_url.dart';
import '../../models/core_lab_test.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lab_test_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../cards/lab_test/error_success_popup.dart';

class CreateLabTestScreen extends ConsumerStatefulWidget {
  final CoreLabTest test;

  const CreateLabTestScreen({super.key, required this.test});

  @override
  ConsumerState<CreateLabTestScreen> createState() =>
      _CreateLabTestScreenState();
}

class _CreateLabTestScreenState extends ConsumerState<CreateLabTestScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();

  String? _selectedSampleTime;
  String? _selectedReportTime;
  late AnimationController _animationController;

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
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _discountController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSampleTime == null || _selectedReportTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select times")));
      return;
    }

    final authState = ref.read(authProvider);
    final labId = authState.user?.id;

    if (labId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User not logged in")));
      return;
    }

    final data = {
      'lab_id': labId,
      'core_test_id': widget.test.coreTestId,
      'sample_collection_time': _selectedSampleTime,
      'report_delivery_time': _selectedReportTime,
      'price': double.parse(_priceController.text),
      'discount_percent': double.tryParse(_discountController.text) ?? 0.0,
      'reviews': [],
    };

    await ref.read(myLabTestProvider.notifier).addToInventory(data);

    if (mounted) {
      final state = ref.read(myLabTestProvider);
      if (state.hasError) {
        final errorMessage = state.error.toString().replaceAll('Exception: ', '');
        ErrorSuccessPopup.show(
          context,
          type: PopupType.error,
          title: "Failed to Add Test",
          message: errorMessage,
        );
        return;
      }
      
      ErrorSuccessPopup.show(
        context,
        type: PopupType.success,
        title: "Success!",
        message: "Test added to inventory successfully",
        onClose: () {
          Navigator.pop(context);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: "Add to Inventory",
        subtitle: widget.test.testName,
        showBackButton: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildFormStep(),
          ),
          _buildActionBottom(),
        ],
      ),
    );
  }

  Widget _buildActionBottom() {
    return Container(
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
          onPressed: _submit,
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
    );
  }

  Widget _buildFormStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCoreTestInfo(),
            const SizedBox(height: AppSpacing.sectionGap),

            // Inventory Details Section
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    IconsaxPlusLinear.wallet_2,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Inventory Details",
                  style: AppTextStyles.subHeader,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sectionGap),

            _buildDropdownField(
              label: "Sample Collection Time",
              value: _selectedSampleTime,
              items: _timeOptions,
              icon: IconsaxPlusLinear.clock,
              onChanged: (val) => setState(() => _selectedSampleTime = val),
            ),
            const SizedBox(height: AppSpacing.elementGap),

            _buildDropdownField(
              label: "Report Delivery Time",
              value: _selectedReportTime,
              items: _timeOptions,
              icon: IconsaxPlusLinear.timer_1,
              onChanged: (val) => setState(() => _selectedReportTime = val),
            ),
            const SizedBox(height: AppSpacing.elementGap),

            _buildPriceField(),
            const SizedBox(height: AppSpacing.elementGap),

            _buildDiscountField(),
            const SizedBox(height: AppSpacing.sectionGap * 2), // Extra space
          ],
        ),
      ),
    );
  }

  Widget _buildCoreTestInfo() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: AppCardStyles.sleekCard,
      child: Row(
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
              image: widget.test.testPhotoUrl != null
                  ? DecorationImage(
                      image: NetworkImage(
                        ApiUrl.imageUrl(widget.test.testPhotoUrl!),
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: widget.test.testPhotoUrl == null
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
                  widget.test.testName,
                  style: AppTextStyles.cardTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildBadge(
                      widget.test.testCategory,
                      IconsaxPlusLinear.category,
                      AppColors.info,
                      AppColors.info.withOpacity(0.15),
                    ),
                    _buildBadge(
                      widget.test.sampleType,
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

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    final effectiveValue = items.contains(value) ? value : null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        border: Border.all(color: AppColors.divider.withAlpha(128)),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: effectiveValue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
          prefixIcon: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 0,
          ),
        ),
        items: items.map((String time) {
          return DropdownMenuItem<String>(
            value: time,
            child: Text(time, style: AppTextStyles.description),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) =>
            value == null ? "Please select a time" : null,
        icon: const Icon(
          IconsaxPlusLinear.arrow_down_1,
          size: 18,
          color: AppColors.primary,
        ),
        dropdownColor: AppColors.surface,
        style:
            AppTextStyles.description.copyWith(color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildPriceField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        border: Border.all(color: AppColors.divider.withAlpha(128)),
      ),
      child: TextFormField(
        controller: _priceController,
        keyboardType: TextInputType.number,
        style: AppTextStyles.description.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: "Price",
          labelStyle: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
          prefixIcon: const Icon(
            IconsaxPlusLinear.money,
            color: AppColors.primary,
            size: 20,
          ),
          prefixText: "₹ ",
          prefixStyle: AppTextStyles.description.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 0,
          ),
        ),
        validator: (value) =>
            (value == null || value.isEmpty) ? "Required" : null,
      ),
    );
  }

  Widget _buildDiscountField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        border: Border.all(color: AppColors.divider.withAlpha(128)),
      ),
      child: TextFormField(
        controller: _discountController,
        keyboardType: TextInputType.number,
        style: AppTextStyles.description.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: "Discount (Optional)",
          labelStyle: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
          prefixIcon: const Icon(
            IconsaxPlusLinear.discount_shape,
            color: AppColors.primary,
            size: 20,
          ),
          suffixText: "%",
          suffixStyle: AppTextStyles.description.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 0,
          ),
        ),
      ),
    );
  }
}
