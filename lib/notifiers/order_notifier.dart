import 'package:flutter_riverpod/legacy.dart';
import '../models/order.dart';
import '../services/order_services.dart';
import 'dart:io';

class OrderState {
  final bool isLoading;
  final String? error;
  final List<Order> orders;

  OrderState({this.isLoading = false, this.error, this.orders = const []});

  OrderState copyWith({bool? isLoading, String? error, List<Order>? orders}) {
    return OrderState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      orders: orders ?? this.orders,
    );
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  final OrderServices _orderServices;
  final String _labId;

  OrderNotifier(this._orderServices, this._labId) : super(OrderState()) {
    if (_labId.isNotEmpty) {
      fetchOrders();
    }
  }

  Future<void> fetchOrders() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _orderServices.getOrdersByLabId(_labId);
      state = state.copyWith(isLoading: false, orders: response.bookings);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Update booking status (and cancellation reason if cancelling)
  Future<void> updateOrderStatus(
    String bookingId,
    String status, {
    String? cancellationReason,
  }) async {
    try {
      await _orderServices.updateOrder(
        bookingId,
        bookingStatus: status,
        cancellationReason: cancellationReason,
      );
      await fetchOrders();
    } catch (e) {
      throw Exception('Failed to update status: $e');
    }
  }

  /// Upload report PDFs via the same update endpoint
  Future<void> uploadReport(String bookingId, List<File> files) async {
    try {
      await _orderServices.updateOrder(bookingId, reportFiles: files);
      await fetchOrders();
    } catch (e) {
      throw Exception('Failed to upload report: $e');
    }
  }
}
