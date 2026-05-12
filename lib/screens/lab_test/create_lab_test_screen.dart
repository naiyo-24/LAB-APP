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
  ConsumerState<CreateLabTestScreen> createState() => _CreateLabTestScreenState();
}

class _CreateLabTestScreenState extends ConsumerState<CreateLabTestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _sampleTimeController = TextEditingController();
  final _reportTimeController = TextEditingController();

  @override
  void dispose() {
    _priceController.dispose();
    _discountController.dispose();
    _sampleTimeController.dispose();
    _reportTimeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

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
      'core_test_id': widget.test.coreTestId,
      'sample_collection_time': _sampleTimeController.text,
      'report_delivery_time': _reportTimeController.text,
      'price': double.parse(_priceController.text),
      'discount_percent': double.tryParse(_discountController.text) ?? 0.0,
      'reviews': [],
    };

    await ref.read(myLabTestProvider.notifier).addToInventory(data);
    
    if (mounted) {
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
              
              TextFormField(
                controller: _sampleTimeController,
                decoration: const InputDecoration(
                  labelText: "Sample Collection Time",
                  hintText: "e.g., 2 hours, 24 hours",
                  prefixIcon: Icon(IconsaxPlusLinear.clock, size: 20),
                ),
                validator: (value) => (value == null || value.isEmpty) ? "Required" : null,
              ),
              const SizedBox(height: AppSpacing.elementGap),
              
              TextFormField(
                controller: _reportTimeController,
                decoration: const InputDecoration(
                  labelText: "Report Delivery Time",
                  hintText: "e.g., 1 day, 2 days, 48 hours",
                  prefixIcon: Icon(IconsaxPlusLinear.timer_1, size: 20),
                ),
                validator: (value) => (value == null || value.isEmpty) ? "Required" : null,
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
          const Icon(IconsaxPlusLinear.document_text, color: AppColors.primary, size: 32),
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
}
