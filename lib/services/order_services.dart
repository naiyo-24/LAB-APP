import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../models/order.dart';
import 'api_url.dart';
import 'dart:io';
import 'package:path/path.dart';

class OrderServices {
  final Dio _dio;

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
      final Map<String, dynamic> formMap = {};

      if (bookingStatus != null) {
        formMap['booking_status'] = bookingStatus;
      }
      if (cancellationReason != null) {
        formMap['cancellation_reason'] = cancellationReason;
      }
      if (labNote != null) {
        formMap['lab_note'] = labNote;
      }

      // Attach report PDFs if provided
      if (reportFiles != null && reportFiles.isNotEmpty) {
        final multipartFiles = <MultipartFile>[];
        for (final file in reportFiles) {
          multipartFiles.add(
            await MultipartFile.fromFile(
              file.path,
              filename: basename(file.path),
            ),
          );
        }
        formMap['files'] = multipartFiles;
      }

      final formData = FormData.fromMap(formMap);

      final response = await _dio.put(
        ApiUrl.updateOrder(bookingId),
        data: formData,
      );

      return Order.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update booking: $e');
    }
  }
}
