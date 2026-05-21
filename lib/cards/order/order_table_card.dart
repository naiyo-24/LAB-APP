import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_theme.dart';
import 'cancellation_bottomsheet.dart';

class OrderTableCard extends ConsumerWidget {
  final List<Order> orders;

  const OrderTableCard({super.key, required this.orders});

  Future<void> _pickAndUploadPdf(
    BuildContext context,
    WidgetRef ref,
    String bookingId,
  ) async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final files = result.files
            .where((f) => f.path != null)
            .map((f) => File(f.path!))
            .toList();
        if (files.isEmpty) return;

        await ref
            .read(orderNotifierProvider.notifier)
            .uploadReport(bookingId, files);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report uploaded successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading report: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleStatusChange(
    BuildContext context,
    WidgetRef ref,
    Order order,
    String? newStatus,
  ) {
    if (newStatus == null || newStatus == order.bookingStatus) return;

    if (newStatus == 'cancelled') {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => CancellationBottomSheet(
          onConfirm: (reason) {
            ref
                .read(orderNotifierProvider.notifier)
                .updateOrderStatus(
                  order.bookingId,
                  newStatus,
                  cancellationReason: reason,
                );
          },
        ),
      );
    } else {
      ref
          .read(orderNotifierProvider.notifier)
          .updateOrderStatus(order.bookingId, newStatus);
    }
  }

  void _downloadReport(BuildContext context, Order order) {
    if (order.reportUrls == null || order.reportUrls!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No reports available for this order.')),
      );
      return;
    }
    // As url_launcher is not installed, we display a placeholder message.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Downloading report: ${order.reportUrls!.first.split('/').last}',
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Helper method for getting status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
      case 'sample_collected':
      case 'testing_in_progress':
        return Colors.blue;
      case 'report_ready':
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  // Format Status for display

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              IconsaxPlusLinear.document,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              "No bookings found",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Bookings',
                      style: AppTextStyles.cardTitle.copyWith(
                        fontSize: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage and track all patient orders',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${orders.length} Total',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
          Expanded(
            child: DataTable2(
              columnSpacing: 16,
              horizontalMargin: 20,
              minWidth: 2800, // Increased to fit all columns
              dataRowHeight: 80, // slightly taller for multiline
              headingRowHeight: 56,
              dividerThickness: 0,
              headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
              columns: [
                DataColumn2(
                  label: Text(
                    'BOOKING ID',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(
                    'DATE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(
                    'TYPE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(
                    'TESTS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(
                    'PATIENT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(
                    'ADDRESS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(
                    'SUB TOTAL',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(
                    'PLATFORM FEE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(
                    'TAX',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(
                    'TOTAL',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(
                    'PAY MODE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text(
                    'NOTE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(
                    'CANCEL REASON',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text(
                    'STATUS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text(
                    'ACTIONS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  size: ColumnSize.S,
                ),
              ],
              rows: orders.asMap().entries.map((entry) {
                final index = entry.key;
                final order = entry.value;

                // Extract patient info
                String patientName = 'N/A';
                String patientPhone = '';
                if (order.patientDetails.isNotEmpty) {
                  patientName =
                      order.patientDetails.first['full_name']?.toString() ??
                      'N/A';
                  patientPhone =
                      order.patientDetails.first['phone_number']?.toString() ??
                      '';
                }

                // Extract test names
                String tests = order.bookedItems
                    .map((item) => item['item_name']?.toString() ?? '')
                    .where((name) => name.isNotEmpty)
                    .join(', ');
                if (tests.isEmpty) tests = 'N/A';

                // Extract address
                String addressStr = 'N/A';
                if (order.sampleCollectionAddress.isNotEmpty) {
                  final addrParts = [
                    order.sampleCollectionAddress['address_1']?.toString(),
                    order.sampleCollectionAddress['street_address']?.toString(),
                  ].where((s) => s != null && s.isNotEmpty).toList();
                  if (addrParts.isNotEmpty) addressStr = addrParts.join(', ');
                }

                final statusColor = _getStatusColor(order.bookingStatus);

                return DataRow2(
                  color: WidgetStateProperty.all(
                    index.isEven
                        ? Colors.white
                        : Colors.grey.shade50.withOpacity(0.5),
                  ),
                  cells: [
                    // Booking ID
                    DataCell(
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(
                                IconsaxPlusLinear.ticket,
                                size: 18,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '#${order.bookingId.length > 8 ? order.bookingId.substring(order.bookingId.length - 8) : order.bookingId}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Date
                    DataCell(
                      Text(
                        order.createdAt.toLocal().toString().split(' ')[0],
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    // Booking Type
                    DataCell(
                      Text(
                        order.bookingType.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    // Tests
                    DataCell(
                      Text(
                        tests,
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Patient
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            patientName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (patientPhone.isNotEmpty)
                            Text(
                              patientPhone,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Address
                    DataCell(
                      Text(
                        addressStr,
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Sub Total Amount
                    DataCell(
                      Text(
                        '₹${order.subTotalAmount}',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    // Platform Fee
                    DataCell(
                      Text(
                        '₹${order.platformFee}',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    // Tax Amount
                    DataCell(
                      Text(
                        '₹${order.taxAmount}',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    // Total Amount
                    DataCell(
                      Text(
                        '₹${order.totalAmountToBePaid}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    // Payment Mode
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          order.paymentMode.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                    // Customer Note
                    DataCell(
                      Text(
                        order.customerNote ?? '-',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Cancellation Reason
                    DataCell(
                      Text(
                        order.cancellationReason ?? '-',
                        style: TextStyle(color: AppColors.error, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Status
                    DataCell(
                      Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: statusColor.withOpacity(0.3),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value:
                                [
                                  'pending',
                                  'accepted',
                                  'sample_collected',
                                  'testing_in_progress',
                                  'report_ready',
                                  'completed',
                                  'cancelled',
                                ].contains(order.bookingStatus)
                                ? order.bookingStatus
                                : 'pending',
                            icon: Icon(
                              IconsaxPlusLinear.arrow_down_1,
                              size: 16,
                              color: statusColor,
                            ),
                            isExpanded: true,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'pending',
                                child: Text('Pending'),
                              ),
                              DropdownMenuItem(
                                value: 'accepted',
                                child: Text('Accepted'),
                              ),
                              DropdownMenuItem(
                                value: 'sample_collected',
                                child: Text('Sample Collected'),
                              ),
                              DropdownMenuItem(
                                value: 'testing_in_progress',
                                child: Text('Testing in Progress'),
                              ),
                              DropdownMenuItem(
                                value: 'report_ready',
                                child: Text('Report Ready'),
                              ),
                              DropdownMenuItem(
                                value: 'completed',
                                child: Text('Completed'),
                              ),
                              DropdownMenuItem(
                                value: 'cancelled',
                                child: Text('Cancelled'),
                              ),
                            ],
                            onChanged: (value) =>
                                _handleStatusChange(context, ref, order, value),
                          ),
                        ),
                      ),
                    ),
                    // Actions
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Tooltip(
                            message: 'Upload Report',
                            child: InkWell(
                              onTap: () => _pickAndUploadPdf(
                                context,
                                ref,
                                order.bookingId,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  IconsaxPlusLinear.document_upload,
                                  color: Colors.blue,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Tooltip(
                            message:
                                (order.reportUrls == null ||
                                    order.reportUrls!.isEmpty)
                                ? 'No report to download'
                                : 'Download Report',
                            child: InkWell(
                              onTap: () => _downloadReport(context, order),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      (order.reportUrls == null ||
                                          order.reportUrls!.isEmpty)
                                      ? Colors.grey.withOpacity(0.1)
                                      : Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  IconsaxPlusLinear.document_download,
                                  color:
                                      (order.reportUrls == null ||
                                          order.reportUrls!.isEmpty)
                                      ? Colors.grey
                                      : Colors.green,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
