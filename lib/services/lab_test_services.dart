import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../models/core_lab_test.dart';
import 'api_url.dart';

import '../models/my_lab_test.dart';

class LabTestServices {
  final Dio _dio = Dio();

  LabTestServices() {
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

  // Core Test Methods
  Future<List<CoreLabTest>> getAllCoreTests({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get(
        ApiUrl.getAllTests,
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final List data = response.data['data'];
        return data.map((json) => CoreLabTest.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load core lab tests');
      }
    } catch (e) {
      throw Exception('Error fetching core lab tests: $e');
    }
  }

  Future<CoreLabTest> getCoreTestById(String testId) async {
    try {
      final response = await _dio.get(ApiUrl.getTestById(testId));

      if (response.statusCode == 200) {
        return CoreLabTest.fromJson(response.data);
      } else {
        throw Exception('Failed to load test details');
      }
    } catch (e) {
      throw Exception('Error fetching test details: $e');
    }
  }

  // Inventory Methods
  Future<MyLabTest> createInventory(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiUrl.createInventory, data: data);
      if (response.statusCode == 200) {
        return MyLabTest.fromJson(response.data);
      } else {
        throw Exception('Failed to create inventory');
      }
    } catch (e) {
      throw Exception('Error creating inventory: $e');
    }
  }

  Future<List<MyLabTest>> getInventoryByLab(String labId, {int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get(
        ApiUrl.getInventoryByLab(labId),
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final List data = response.data['data'];
        return data.map((json) => MyLabTest.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load lab inventory');
      }
    } catch (e) {
      throw Exception('Error fetching lab inventory: $e');
    }
  }

  Future<MyLabTest> getInventoryById(String testId) async {
    try {
      final response = await _dio.get(ApiUrl.getInventoryById(testId));
      if (response.statusCode == 200) {
        return MyLabTest.fromJson(response.data);
      } else {
        throw Exception('Failed to load inventory details');
      }
    } catch (e) {
      throw Exception('Error fetching inventory details: $e');
    }
  }

  Future<MyLabTest> updateInventory(String testId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(ApiUrl.updateInventory(testId), data: data);
      if (response.statusCode == 200) {
        return MyLabTest.fromJson(response.data);
      } else {
        throw Exception('Failed to update inventory');
      }
    } catch (e) {
      throw Exception('Error updating inventory: $e');
    }
  }

  Future<void> deleteInventory(List<String> testIds) async {
    try {
      final response = await _dio.delete(ApiUrl.deleteInventory, data: testIds);
      if (response.statusCode != 200) {
        throw Exception('Failed to delete inventory items');
      }
    } catch (e) {
      throw Exception('Error deleting inventory: $e');
    }
  }
}
