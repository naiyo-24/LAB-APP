import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class IncomingOrderPopup extends ConsumerWidget {
  final Order order;

  const IncomingOrderPopup({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine the main patient name and tests summary
    String patientName = 'Unknown Patient';
    if (order.patientDetails.isNotEmpty) {
      patientName = order.patientDetails.first['name'] ?? 'Unknown Patient';
    }

    // Prepare a string of requested tests
    final List<String> testNames = [];
    if (order.bookedItems.isNotEmpty) {
      testNames.addAll(order.bookedItems.map((item) => (item['test_name'] ?? item['package_name'] ?? 'Unknown Item').toString()));
    }
    
    final testsSummary = testNames.join(', ');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.borderRadius)),
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(IconsaxPlusBold.notification, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.elementGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'New Booking Request!',
                        style: AppTextStyles.subHeader,
                      ),
                      Text(
                        order.bookingId,
                        style: AppTextStyles.caption.copyWith(color: AppColors.silver),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(IconsaxPlusLinear.close_circle, color: AppColors.silver),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sectionGap),

            // Content
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  _buildDetailRow(IconsaxPlusLinear.user, 'Patient', patientName),
                  const Divider(height: 24, color: AppColors.divider),
                  _buildDetailRow(IconsaxPlusLinear.clipboard_text, 'Tests', testsSummary.isEmpty ? 'Custom Request' : testsSummary),
                  const Divider(height: 24, color: AppColors.divider),
                  _buildDetailRow(IconsaxPlusLinear.card, 'Total Amount', '₹${order.totalAmountToBePaid.toStringAsFixed(2)}'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      try {
                        await ref.read(orderNotifierProvider.notifier).updateOrderStatus(
                          order.bookingId,
                          'Rejected',
                          cancellationReason: 'Rejected by Lab Admin',
                        );
                        if (context.mounted) Navigator.of(context).pop();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: AppSpacing.elementGap),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await ref.read(orderNotifierProvider.notifier).updateOrderStatus(
                          order.bookingId,
                          'Accepted',
                        );
                        if (context.mounted) Navigator.of(context).pop();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.silver),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(color: AppColors.silver),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.description.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
