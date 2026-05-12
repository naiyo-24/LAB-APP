import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../models/my_lab_test.dart';
import '../../models/test_package.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lab_test_provider.dart';
import '../../providers/package_provider.dart';
import '../../theme/app_theme.dart';

class PackageBottomSheet extends ConsumerStatefulWidget {
  final TestPackage package;

  const PackageBottomSheet({super.key, required this.package});

  @override
  ConsumerState<PackageBottomSheet> createState() => _PackageBottomSheetState();
}

class _PackageBottomSheetState extends ConsumerState<PackageBottomSheet> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _marketPriceController;
  late TextEditingController _discountController;
  late List<dynamic> _currentTests;
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
    _nameController = TextEditingController(text: widget.package.packageName);
    _descController = TextEditingController(
      text: widget.package.packageDescription,
    );
    _marketPriceController = TextEditingController(
      text: widget.package.packageMarketPrice.toString(),
    );
    _discountController = TextEditingController(
      text: widget.package.discountPercentage.toString(),
    );
    _currentTests = List.from(widget.package.testDetails);
    _selectedSampleTime = widget.package.packageSampleCollectionTime;
    _selectedReportTime = widget.package.packageReportDeliveryTime;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _marketPriceController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  double get _finalPrice {
    final market = double.tryParse(_marketPriceController.text) ?? 0.0;
    final discount = double.tryParse(_discountController.text) ?? 0.0;
    return market - (market * discount / 100);
  }

  Future<void> _handleSave() async {
    final data = {
      'package_name': _nameController.text,
      'package_description': _descController.text,
      'package_market_price': double.parse(_marketPriceController.text),
      'discount_percentage': double.tryParse(_discountController.text) ?? 0.0,
      'test_ids': _currentTests.map((t) => t['test_id']).toList(),
      'package_sample_collection_time': _selectedSampleTime,
      'package_report_delivery_time': _selectedReportTime,
    };

    await ref
        .read(packageProvider.notifier)
        .updatePackage(widget.package.packageId, data);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.divider.withAlpha(50)),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(IconsaxPlusLinear.close_circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isEditing ? "Edit Package" : "Package Details",
                        style: AppTextStyles.subHeader,
                      ),
                    ),
                    if (!_isEditing)
                      IconButton(
                        onPressed: () => setState(() => _isEditing = true),
                        icon: const Icon(
                          IconsaxPlusLinear.edit,
                          color: AppColors.primary,
                        ),
                      )
                    else
                      TextButton(
                        onPressed: _handleSave,
                        child: const Text(
                          "Save",
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Body
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    if (_isEditing) ...[
                      _buildTextField("Package Name", _nameController),
                      const SizedBox(height: 16),
                      _buildTextField(
                        "Description",
                        _descController,
                        maxLines: 3,
                      ),
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
                              (val) =>
                                  setState(() => _selectedSampleTime = val),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTimeDropdown(
                              "Report Delivery",
                              _selectedReportTime,
                              (val) =>
                                  setState(() => _selectedReportTime = val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Final Price: ₹${_finalPrice.toStringAsFixed(0)}",
                        style: AppTextStyles.cardTitle.copyWith(
                          color: AppColors.primaryAccent,
                        ),
                      ),
                    ] else ...[
                      Text(
                        widget.package.packageName,
                        style: AppTextStyles.header,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.package.packageDescription ??
                            "No description provided",
                        style: AppTextStyles.description,
                      ),
                      const SizedBox(height: 24),
                      _buildInfoRow(
                        IconsaxPlusLinear.money,
                        "Market Price",
                        "₹${widget.package.packageMarketPrice}",
                      ),
                      _buildInfoRow(
                        IconsaxPlusLinear.percentage_square,
                        "Discount",
                        "${widget.package.discountPercentage}%",
                      ),
                      _buildInfoRow(
                        IconsaxPlusLinear.timer_1,
                        "Sample Collection",
                        widget.package.packageSampleCollectionTime,
                      ),
                      _buildInfoRow(
                        IconsaxPlusLinear.truck,
                        "Report Delivery",
                        widget.package.packageReportDeliveryTime,
                      ),
                      _buildInfoRow(
                        IconsaxPlusLinear.wallet,
                        "Final Price",
                        "₹${widget.package.packageFinalPrice}",
                        isHighlight: true,
                      ),
                    ],
                    const SizedBox(height: 32),
                    Text(
                      "Included Tests (${_currentTests.length})",
                      style: AppTextStyles.subHeader,
                    ),
                    const SizedBox(height: 16),
                    ..._currentTests.asMap().entries.map((entry) {
                      final test = entry.value;
                      final String testName =
                          test['test_name'] ??
                          test['core_test_details']?['test_name'] ??
                          'Unknown Test';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: AppCardStyles.sleekCard.copyWith(
                          color: AppColors.background,
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: _isEditing
                              ? null
                              : () {
                                  final myTest = MyLabTest.fromJson(test);
                                  context.push('/test-details', extra: myTest);
                                },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withAlpha(20),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        IconsaxPlusLinear.document_text,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        testName,
                                        style: AppTextStyles.cardTitle,
                                      ),
                                    ),
                                    if (_isEditing)
                                      IconButton(
                                        onPressed: () => setState(
                                          () =>
                                              _currentTests.removeAt(entry.key),
                                        ),
                                        icon: const Icon(
                                          IconsaxPlusLinear.trash,
                                          color: AppColors.error,
                                          size: 20,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildMiniBadge(
                                      IconsaxPlusLinear.money,
                                      "₹${test['price'] ?? '0'}",
                                    ),
                                    _buildMiniBadge(
                                      IconsaxPlusLinear.timer_1,
                                      test['sample_collection_time'] ?? 'N/A',
                                    ),
                                    _buildMiniBadge(
                                      IconsaxPlusLinear.truck,
                                      test['report_delivery_time'] ?? 'N/A',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    if (_isEditing)
                      OutlinedButton.icon(
                        onPressed: _showTestPicker,
                        icon: const Icon(IconsaxPlusLinear.add_circle),
                        label: const Text("Add More Tests"),
                      ),
                    const SizedBox(height: 32),
                    if (!_isEditing)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Delete Package"),
                                content: const Text(
                                  "Are you sure you want to remove this package?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
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
                                  .read(packageProvider.notifier)
                                  .deletePackage(widget.package.packageId);
                              if (context.mounted) Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error.withAlpha(20),
                            foregroundColor: AppColors.error,
                          ),
                          child: const Text("Delete Package"),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTestPicker() {
    final user = ref.read(authProvider).user;
    if (user?.id != null) {
      ref.read(myLabTestProvider.notifier).fetchMyTests(user!.id!);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final myTestsAsync = ref.watch(myLabTestProvider);

          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                AppBar(
                  title: const Text("Select Tests"),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(IconsaxPlusLinear.close_circle),
                  ),
                ),
                Expanded(
                  child: myTestsAsync.when(
                    data: (tests) {
                      if (tests.isEmpty) {
                        return const Center(
                          child: Text("No tests found in inventory"),
                        );
                      }
                      return ListView.builder(
                        itemCount: tests.length,
                        itemBuilder: (context, index) {
                          final test = tests[index];
                          final bool alreadyAdded = _currentTests.any(
                            (t) => t['test_id'] == test.testId,
                          );

                          return ListTile(
                            title: Text(
                              test.coreTestDetails?.testName ?? "Test",
                            ),
                            subtitle: Text(
                              test.coreTestDetails?.testCategory ?? "",
                            ),
                            trailing: Icon(
                              alreadyAdded
                                  ? IconsaxPlusBold.tick_circle
                                  : IconsaxPlusLinear.add_circle,
                              color: alreadyAdded
                                  ? AppColors.success
                                  : AppColors.primary,
                            ),
                            onTap: alreadyAdded
                                ? null
                                : () {
                                    setState(() {
                                      _currentTests.add({
                                        'test_id': test.testId,
                                        'core_test_id': test.coreTestId,
                                        'test_name':
                                            test.coreTestDetails?.testName ??
                                            'Unknown Test',
                                        'test_description':
                                            test.coreTestDetails?.description ??
                                            '',
                                        'test_parameters':
                                            test.coreTestDetails?.parameters ??
                                            [],
                                        'test_photos':
                                            test
                                                .coreTestDetails
                                                ?.testPhotoUrl ??
                                            '',
                                        'test_precautions':
                                            test.coreTestDetails?.precautions ??
                                            [],
                                        'price': test.price,
                                        'sample_collection_time':
                                            test.sampleCollectionTime,
                                        'report_delivery_time':
                                            test.reportDeliveryTime,
                                      });
                                    });
                                    Navigator.pop(context);
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
              ],
            ),
          );
        },
      ),
    );
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
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _buildInfoRow(
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
              color: isHighlight
                  ? AppColors.primaryAccent
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.divider.withAlpha(30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textTertiary),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.tagline.copyWith(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
