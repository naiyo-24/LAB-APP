import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../models/core_lab_test.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lab_test_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';

class CreateLabTestScreen extends ConsumerStatefulWidget {
  final CoreLabTest test;

  const CreateLabTestScreen({super.key, required this.test});

  @override
  ConsumerState<CreateLabTestScreen> createState() =>
      _CreateLabTestScreenState();
}

class _CreateLabTestScreenState extends ConsumerState<CreateLabTestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();

  String? _selectedSampleTime;
  String? _selectedReportTime;

  final List<String> _timeOptions = [
    "within 2 hours",
    "4 hours",
    "10 hours",
    "24 hours",
    "2 days",
    "4 days",
    "7 days",
  ];

  @override
  void dispose() {
    _priceController.dispose();
    _discountController.dispose();
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
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Test added to inventory")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: "Add to Inventory",
        subtitle: widget.test.testName,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCoreTestInfo(),
              const SizedBox(height: AppSpacing.sectionGap),

              const Text("Inventory Details", style: AppTextStyles.subHeader),
              const SizedBox(height: AppSpacing.elementGap),

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
              const SizedBox(height: AppSpacing.elementGap),

              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Price",
                  prefixText: "₹ ",
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? "Required" : null,
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
              const SizedBox(height: AppSpacing.sectionGap),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text("Add to Inventory"),
                ),
              ),
            ],
          ),
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
          const Icon(
            IconsaxPlusLinear.document_text,
            color: AppColors.primary,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.test.testName, style: AppTextStyles.cardTitle),
                Text(widget.test.testCategory, style: AppTextStyles.caption),
              ],
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
      validator: (value) => value == null ? "Please select a time" : null,
      icon: const Icon(IconsaxPlusLinear.arrow_down_1, size: 18),
      dropdownColor: AppColors.surface,
      style: AppTextStyles.description.copyWith(color: AppColors.textPrimary),
    );
  }
}
