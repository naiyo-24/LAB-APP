import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CancellationBottomSheet extends StatefulWidget {
  final Function(String) onConfirm;

  const CancellationBottomSheet({super.key, required this.onConfirm});

  @override
  State<CancellationBottomSheet> createState() =>
      _CancellationBottomSheetState();
}

class _CancellationBottomSheetState extends State<CancellationBottomSheet> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cancel Booking', style: AppTextStyles.cardTitle),
          const SizedBox(height: 16),
          const Text(
            'Please provide a reason for cancellation.',
            style: AppTextStyles.description,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _reasonController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter reason here...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  onPressed: () {
                    final reason = _reasonController.text.trim();
                    Navigator.pop(context);
                    widget.onConfirm(reason);
                  },
                  child: const Text(
                    'Confirm Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
