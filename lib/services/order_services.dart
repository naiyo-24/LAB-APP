import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../models/order.dart';
import 'api_url.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class OrderServices {
  final Dio _dio;
  static const String _tokenKey = 'jwt_access_token';

  Future<String?> _getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  OrderServices() : _dio = Dio() {
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    ));
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _getSavedToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  /// GET /lab/{lab_id} — fetch all bookings for a lab
  Future<OrderListResponse> getOrdersByLabId(String labId) async {
    try {
      final response = await _dio.get(ApiUrl.getOrdersByLab(labId));
      return OrderListResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch lab orders: $e');
    }
  }

  /// GET /details/{booking_id} — fetch single booking detail
  Future<Order> getOrderDetails(String bookingId) async {
    try {
      final response = await _dio.get(ApiUrl.getOrderDetails(bookingId));
      return Order.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch order details: $e');
    }
  }

  /// PUT /update/{booking_id} — update booking status, cancellation reason,
  /// lab note, and/or upload report files. All sent as multipart/form-data
  /// to match the FastAPI Form() + File() signature.
  Future<Order> updateOrder(
    String bookingId, {
    String? bookingStatus,
    String? cancellationReason,
    String? labNote,
    List<File>? reportFiles,
  }) async {
    try {
      final Map<String, dynamic> data = {};

      if (bookingStatus != null) {
        data['new_status'] = bookingStatus;
      }
      
      // Note: The new backend doesn't currently support cancellation reason, lab note, or report files in this endpoint.
      // We will only send the new_status for now.

      final response = await _dio.put(
        ApiUrl.updateOrder(bookingId),
        data: data,
      );

      return Order.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update booking: $e');
    }
  }
}
