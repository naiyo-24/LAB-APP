import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/order.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/side_nav_bar.dart';
import '../../providers/order_provider.dart';
import '../../cards/order/order_table_card.dart';
import '../../cards/order/order_search_filter_card.dart';
import '../../widgets/main_screen_pop_scope.dart';

class OrderManagementScreen extends ConsumerStatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  ConsumerState<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends ConsumerState<OrderManagementScreen> {
  bool _isFilterVisible = false;
  String _searchQuery = '';
  String _statusFilter = 'All';

  Future<void> _exportToCsv(List<Order> orders) async {
    try {
      List<List<dynamic>> rows = [];
      
      // Header row
      rows.add([
        'Booking ID',
        'Date',
        'Tests',
        'Patient',
        'Sub Total',
        'Platform Fee',
        'Tax',
        'Total',
        'Payment Mode',
        'Note',
        'Cancel Reason',
        'Status'
      ]);

      // Data rows
      for (var order in orders) {
        String patientName = 'N/A';
        if (order.patientDetails.isNotEmpty) {
          patientName = order.patientDetails.first['full_name']?.toString() ??
              order.patientDetails.first['name']?.toString() ??
              'N/A';
        }

        String tests = order.bookedItems
            .map((item) => item['item_name']?.toString() ?? item['test_name']?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .join(', ');

        rows.add([
          order.bookingId,
          order.createdAt.toLocal().toString(),
          tests,
          patientName,
          order.subTotalAmount,
          order.platformFee,
          order.taxAmount,
          order.totalAmountToBePaid,
          order.paymentMode,
          order.customerNote ?? '',
          order.cancellationReason ?? '',
          order.bookingStatus,
        ]);
      }

      String csvString = csv.encode(rows);
      
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/orders_export_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(path);
      await file.writeAsString(csvString);

      if (mounted) {
        await Share.shareXFiles([XFile(path)], text: 'Orders Export CSV');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export CSV: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderNotifierProvider);

    // Apply filtering
    var filteredOrders = orderState.orders.where((order) {
      if (_statusFilter != 'All' && order.bookingStatus.toLowerCase() != _statusFilter.toLowerCase()) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        // Assuming customer or patient name can be searched.
        // The exact structure of patientDetails might vary, we'll assume it has a name or phone property.
        bool match = false;
        if (order.patientDetails.isNotEmpty) {
          for (var patient in order.patientDetails) {
            final name = (patient['name'] ?? '').toString().toLowerCase();
            final phone = (patient['phone'] ?? '').toString().toLowerCase();
            if (name.contains(query) || phone.contains(query)) {
              match = true;
              break;
            }
          }
        }
        if (!match) return false;
      }
      return true;
    }).toList();

    return MainScreenPopScope(
      child: Scaffold(
        appBar: CustomAppBar(
        title: 'Orders & Bookings',
        subtitle: 'Manage your patient bookings',
        showDrawer: true,
        actions: [
          IconButton(
            icon: const Icon(
              IconsaxPlusLinear.document_download,
              color: AppColors.textPrimary,
            ),
            tooltip: 'Export to CSV',
            onPressed: () => _exportToCsv(filteredOrders),
          ),
          IconButton(
            icon: Icon(
              IconsaxPlusLinear.filter,
              color: _isFilterVisible ? AppColors.primary : AppColors.textPrimary,
            ),
            onPressed: () {
              setState(() {
                _isFilterVisible = !_isFilterVisible;
              });
            },
          ),
        ],
      ),
      drawer: const SideNavBar(),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          if (_isFilterVisible)
            OrderSearchFilterCard(
              onSearchChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
              onStatusFilterChanged: (status) {
                setState(() {
                  _statusFilter = status;
                });
              },
              currentStatus: _statusFilter,
            ),
          Expanded(
            child: orderState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : orderState.error != null
                    ? Center(child: Text('Error: ${orderState.error}', style: const TextStyle(color: AppColors.error)))
                    : filteredOrders.isEmpty
                        ? const Center(child: Text('No orders found.'))
                        : Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: OrderTableCard(orders: filteredOrders),
                          ),
          ),
        ],
      ),
    ));
  }
}
