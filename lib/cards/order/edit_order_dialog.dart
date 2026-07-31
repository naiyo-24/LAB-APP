import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';

class EditOrderDialog extends ConsumerStatefulWidget {
  final Order order;

  const EditOrderDialog({super.key, required this.order});

  @override
  ConsumerState<EditOrderDialog> createState() => _EditOrderDialogState();
}

class _EditOrderDialogState extends ConsumerState<EditOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _ageController;
  late TextEditingController _priceController;
  String _paymentMode = 'cod';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    String currentName = '';
    String currentPhone = '';
    String currentAge = '';

    if (widget.order.patientDetails.isNotEmpty) {
      final p = widget.order.patientDetails.first;
      currentName = (p['full_name'] ?? p['name'] ?? '').toString();
      currentPhone = (p['phone_number'] ?? p['phone'] ?? '').toString();
      currentAge = (p['age'] ?? '').toString();
    }

    _nameController = TextEditingController(text: currentName);
    _phoneController = TextEditingController(text: currentPhone);
    _ageController = TextEditingController(text: currentAge);
    _priceController = TextEditingController(text: widget.order.totalAmountToBePaid.toString());
    _paymentMode = widget.order.paymentMode.toLowerCase() == 'online' ? 'online' : 'cod';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final double? price = double.tryParse(_priceController.text);
      await ref.read(orderNotifierProvider.notifier).editOrderDetails(
            widget.order.bookingId,
            patientName: _nameController.text.trim(),
            patientPhone: _phoneController.text.trim(),
            patientAge: _ageController.text.trim(),
            totalPrice: price,
            paymentMode: _paymentMode,
          );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Order ${widget.order.bookingId}'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Patient Name'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Patient Phone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Patient Age'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Total Price'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (double.tryParse(val) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _paymentMode,
                decoration: const InputDecoration(labelText: 'Payment Mode'),
                items: const [
                  DropdownMenuItem(value: 'cod', child: Text('Cash on Delivery (COD)')),
                  DropdownMenuItem(value: 'online', child: Text('Online')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _paymentMode = val);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
        ),
      ],
    );
  }
}
