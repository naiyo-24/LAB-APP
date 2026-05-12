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
    "within 2 hours",
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Package Details"),
              const SizedBox(height: 16),
              _buildTextField("Package Name", _nameController),
              const SizedBox(height: 16),
              _buildTextField("Description", _descController, maxLines: 2),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      "Market Price",
                      _marketPriceController,
                      isNumber: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      "Discount %",
                      _discountController,
                      isNumber: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTimeDropdown(
                      "Sample Collection",
                      _selectedSampleTime,
                      (val) => setState(() => _selectedSampleTime = val),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimeDropdown(
                      "Report Delivery",
                      _selectedReportTime,
                      (val) => setState(() => _selectedReportTime = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildSectionTitle("Included Tests (${_selectedTests.length})"),
              const SizedBox(height: 12),
              if (_selectedTests.isEmpty)
                const Text("No tests added yet", style: AppTextStyles.caption)
              else
                Wrap(
                  spacing: 8,
                  children: _selectedTests
                      .map(
                        (test) => Chip(
                          label: Text(test.coreTestDetails?.testName ?? "Test"),
                          onDeleted: () =>
                              setState(() => _selectedTests.remove(test)),
                          backgroundColor: AppColors.surface,
                          side: const BorderSide(color: AppColors.divider),
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 24),

              _buildSectionTitle("Add Tests from Inventory"),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                onChanged: (val) =>
                    ref.read(myLabTestProvider.notifier).searchMyTests(val),
                decoration: const InputDecoration(
                  hintText: "Search your inventory...",
                  prefixIcon: Icon(IconsaxPlusLinear.search_normal),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 300,
                child: myTestsAsync.when(
                  data: (tests) {
                    return ListView.builder(
                      itemCount: tests.length,
                      itemBuilder: (context, index) {
                        final test = tests[index];
                        final isSelected = _selectedTests.contains(test);
                        return ListTile(
                          title: Text(test.coreTestDetails?.testName ?? ""),
                          subtitle: Text("Price: ₹${test.marketPrice}"),
                          trailing: Icon(
                            isSelected
                                ? IconsaxPlusBold.tick_circle
                                : IconsaxPlusLinear.add_circle,
                            color: isSelected
                                ? AppColors.success
                                : AppColors.primary,
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
                  error: (err, stack) => Text("Error: $err"),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(
                    "Create Package for ₹${_finalPrice.toStringAsFixed(0)}",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.subHeader);
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      onChanged: (_) => setState(() {}),
      validator: (val) => (val == null || val.isEmpty) ? "Required" : null,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _buildTimeDropdown(
    String label,
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
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
      decoration: InputDecoration(labelText: label),
    );
  }
}
