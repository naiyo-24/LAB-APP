import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../models/core_lab_test.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lab_test_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../cards/lab_test/test_error_card.dart';
import '../../services/api_url.dart';

class CreateLabTestScreen extends ConsumerStatefulWidget {
  final CoreLabTest? test;

  const CreateLabTestScreen({super.key, this.test});

  @override
  ConsumerState<CreateLabTestScreen> createState() => _CreateLabTestScreenState();
}

class _CreateLabTestScreenState extends ConsumerState<CreateLabTestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _searchController = TextEditingController();

  String? _selectedSampleTime;
  String? _selectedReportTime;
  CoreLabTest? _selectedTest;

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
  void initState() {
    super.initState();
    _selectedTest = widget.test;
  }

  @override
  void dispose() {
    _priceController.dispose();
    _discountController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSampleTime == null || _selectedReportTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select times")),
      );
      return;
    }

    final authState = ref.read(authProvider);
    final labId = authState.user?.id;

    if (labId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    final data = {
      'lab_id': labId,
      'core_test_id': _selectedTest!.coreTestId,
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
        TestErrorCard.show(
          context,
          state.error.toString().replaceAll('Exception: ', ''),
        );
        return;
      }
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Test added to inventory")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: _selectedTest == null ? "Search Tests" : "Add to Inventory",
        subtitle: _selectedTest?.testName ?? "Browse available tests",
        showBackButton: true,
        onBackPress: _selectedTest != null ? () => setState(() => _selectedTest = null) : null,
      ),
      body: _selectedTest == null ? _buildSearchStep() : _buildFormStep(),
    );
  }

  Widget _buildSearchStep() {
    final availableTestsAsync = ref.watch(coreLabTestProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => ref.read(coreLabTestProvider.notifier).searchTests(val),
            decoration: InputDecoration(
              hintText: "Search by test name or category...",
              prefixIcon: const Icon(IconsaxPlusLinear.search_normal),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: availableTestsAsync.when(
            data: (tests) {
              if (tests.isEmpty) {
                return const Center(child: Text("No available tests found"));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                itemCount: tests.length,
                itemBuilder: (context, index) {
                  final test = tests[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: AppCardStyles.sleekCard,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.background,
                          image: test.testPhotoUrl != null
                              ? DecorationImage(
                                  image: NetworkImage("${ApiUrl.baseUrl}/${test.testPhotoUrl}"),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: test.testPhotoUrl == null ? const Icon(IconsaxPlusLinear.box) : null,
                      ),
                      title: Text(test.testName, style: AppTextStyles.cardTitle),
                      subtitle: Text(test.testCategory, style: AppTextStyles.caption),
                      trailing: const Icon(IconsaxPlusLinear.arrow_right_3),
                      onTap: () => setState(() => _selectedTest = test),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text("Error: $err")),
          ),
        ),
      ],
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
              validator: (value) => (value == null || value.isEmpty) ? "Required" : null,
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

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _selectedTest = null),
                    child: const Text("Change Test"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text("Add to Inventory"),
                  ),
                ),
              ],
            ),
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
          const Icon(IconsaxPlusLinear.document_text, color: AppColors.primary, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_selectedTest?.testName ?? "", style: AppTextStyles.cardTitle),
                Text(_selectedTest?.testCategory ?? "", style: AppTextStyles.caption),
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
    final effectiveValue = items.contains(value) ? value : null;

    return DropdownButtonFormField<String>(
      value: effectiveValue,
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
