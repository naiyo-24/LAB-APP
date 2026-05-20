import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../models/my_lab_test.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lab_test_provider.dart';
import '../../providers/package_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';

class CreatePackageScreen extends ConsumerStatefulWidget {
  const CreatePackageScreen({super.key});

  @override
  ConsumerState<CreatePackageScreen> createState() =>
      _CreatePackageScreenState();
}

class _CreatePackageScreenState extends ConsumerState<CreatePackageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _marketPriceController = TextEditingController();
  final _discountController = TextEditingController();

  final List<MyLabTest> _selectedTests = [];
  final TextEditingController _searchController = TextEditingController();

  final List<String> _timeOptions = [
    "Within 2 hours",
    "4 hours",
    "10 hours",
    "24 hours",
    "2 days",
    "4 days",
    "7 days",
  ];

  String? _selectedSampleTime;
  String? _selectedReportTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user?.id != null) {
        ref.read(myLabTestProvider.notifier).fetchMyTests(user!.id!);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _marketPriceController.dispose();
    _discountController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  double get _finalPrice {
    final market = double.tryParse(_marketPriceController.text) ?? 0.0;
    final discount = double.tryParse(_discountController.text) ?? 0.0;
    return market - (market * discount / 100);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTests.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Add at least one test")));
      return;
    }

    final user = ref.read(authProvider).user;
    final data = {
      'lab_id': user?.id,
      'package_name': _nameController.text,
      'package_description': _descController.text,
      'test_ids': _selectedTests.map((t) => t.testId).toList(),
      'package_sample_collection_time': _selectedSampleTime ?? "24 hours",
      'package_report_delivery_time': _selectedReportTime ?? "48 hours",
      'package_market_price': double.parse(_marketPriceController.text),
      'discount_percentage': double.tryParse(_discountController.text) ?? 0.0,
    };

    await ref.read(packageProvider.notifier).createPackage(data);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final myTestsAsync = ref.watch(myLabTestProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: "Create Package",
        subtitle: "Bundle tests together",
        showBackButton: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Package Details", style: AppTextStyles.subHeader),
                    const SizedBox(height: AppSpacing.elementGap),
                    
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.cardPadding),
                      decoration: AppCardStyles.sleekCard,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            "Package Name", 
                            _nameController,
                            icon: IconsaxPlusLinear.box,
                            hintText: "e.g., Full Body Checkup",
                          ),
                          const SizedBox(height: AppSpacing.elementGap),
                          _buildTextField(
                            "Description", 
                            _descController, 
                            maxLines: 5,
                            icon: IconsaxPlusLinear.document_text_1,
                            hintText: "Included tests and benefits...",
                          ),
                          const SizedBox(height: AppSpacing.elementGap),
                          _buildTextField(
                            "MRP in INR",
                            _marketPriceController,
                            isNumber: true,
                            icon: IconsaxPlusLinear.tag,
                            hintText: "₹ 0.00",
                          ),
                          const SizedBox(height: AppSpacing.elementGap),
                          _buildTextField(
                            "Discount %",
                            _discountController,
                            isNumber: true,
                            icon: IconsaxPlusLinear.discount_shape,
                            hintText: "0 %",
                          ),
                          const SizedBox(height: AppSpacing.elementGap),
                          _buildTimeDropdown(
                            "Sample Collection Time",
                            _selectedSampleTime,
                            (val) => setState(() => _selectedSampleTime = val),
                            icon: IconsaxPlusLinear.clock,
                          ),
                          const SizedBox(height: AppSpacing.elementGap),
                          _buildTimeDropdown(
                            "Report Delivery Time",
                            _selectedReportTime,
                            (val) => setState(() => _selectedReportTime = val),
                            icon: IconsaxPlusLinear.document_forward,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),

                    Text("Included Tests (${_selectedTests.length})", style: AppTextStyles.subHeader),
                    const SizedBox(height: AppSpacing.elementGap),
                    if (_selectedTests.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.cardPadding),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.divider.withOpacity(0.5)),
                        ),
                        child: Text(
                          "No tests added yet.\nSearch and select tests from inventory below.",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedTests
                            .map(
                              (test) => Chip(
                                label: Text(test.coreTestDetails?.testName ?? "Test", style: AppTextStyles.description),
                                onDeleted: () =>
                                    setState(() => _selectedTests.remove(test)),
                                backgroundColor: AppColors.surface,
                                deleteIcon: const Icon(IconsaxPlusLinear.close_circle, size: 20, color: AppColors.error),
                                side: const BorderSide(color: AppColors.divider),
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: AppSpacing.sectionGap),

                    Text("Add Tests from Inventory", style: AppTextStyles.subHeader),
                    const SizedBox(height: AppSpacing.elementGap),
                    TextFormField(
                      controller: _searchController,
                      onChanged: (val) =>
                          ref.read(myLabTestProvider.notifier).searchMyTests(val),
                      decoration: const InputDecoration(
                        hintText: "Search your inventory...",
                        prefixIcon: Icon(IconsaxPlusLinear.search_normal, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.elementGap),
                    
                    Container(
                      height: 320,
                      decoration: AppCardStyles.sleekCard,
                      clipBehavior: Clip.antiAlias,
                      child: myTestsAsync.when(
                        data: (tests) {
                          if (tests.isEmpty) {
                            return const Center(child: Text("No tests found"));
                          }
                          return ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: tests.length,
                            separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.divider),
                            itemBuilder: (context, index) {
                              final test = tests[index];
                              final isSelected = _selectedTests.contains(test);
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                title: Text(
                                  test.coreTestDetails?.testName ?? "",
                                  style: AppTextStyles.description.copyWith(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  "₹${test.marketPrice}",
                                  style: AppTextStyles.caption.copyWith(color: AppColors.success),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.success.withOpacity(0.1) : AppColors.surface,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? AppColors.success : AppColors.divider,
                                    ),
                                  ),
                                  child: Icon(
                                    isSelected
                                        ? IconsaxPlusBold.tick_circle
                                        : IconsaxPlusLinear.add,
                                    size: 20,
                                    color: isSelected
                                        ? AppColors.success
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedTests.remove(test);
                                    } else {
                                      _selectedTests.add(test);
                                    }
                                  });
                                },
                              );
                            },
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (err, stack) => Center(child: Text("Error: $err")),
                      ),
                    ),
                    
                    const SizedBox(height: 48), // Padding below content
                  ],
                ),
              ),
            ),
          ),
          _buildActionBottom(),
        ],
      ),
    );
  }

  Widget _buildActionBottom() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(IconsaxPlusLinear.add),
            label: Text("Create Package for ₹${_finalPrice.toStringAsFixed(0)}"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    int maxLines = 1,
    IconData? icon,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      onChanged: (_) => setState(() {}),
      validator: (val) => (val == null || val.isEmpty) ? "Required" : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: icon != null 
            ? Icon(icon, color: AppColors.primary, size: 22)
            : null,
      ),
    );
  }

  Widget _buildTimeDropdown(
    String label,
    String? value,
    ValueChanged<String?> onChanged, {
    IconData? icon,
  }) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: value,
      items: _timeOptions
          .map(
            (time) => DropdownMenuItem(
              value: time,
              child: Text(time, style: AppTextStyles.description),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? "Required" : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: AppColors.primary, size: 22) : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
    );
  }
}
