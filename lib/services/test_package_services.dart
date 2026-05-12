import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../models/test_package.dart';
import 'api_url.dart';

class TestPackageServices {
  final Dio _dio = Dio();

  TestPackageServices() {
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

  Future<TestPackage> createPackage(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiUrl.createPackage, data: data);
      if (response.statusCode == 200) {
        return TestPackage.fromJson(response.data);
      } else {
        throw Exception('Failed to create package');
      }
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? e.message ?? 'Unknown error';
      throw Exception(message);
    }
  }

  Future<List<TestPackage>> getPackagesByLab(String labId) async {
    try {
      final response = await _dio.get(ApiUrl.getPackagesByLab(labId));
      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        return data.map((json) => TestPackage.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load packages');
      }
    } catch (e) {
      throw Exception('Error fetching packages: $e');
    }
  }

  Future<TestPackage> getPackageById(String packageId) async {
    try {
      final response = await _dio.get(ApiUrl.getPackageById(packageId));
      if (response.statusCode == 200) {
        return TestPackage.fromJson(response.data);
      } else {
        throw Exception('Failed to load package details');
      }
    } catch (e) {
      throw Exception('Error fetching package details: $e');
    }
  }

  Future<TestPackage> updatePackage(String packageId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(ApiUrl.updatePackage(packageId), data: data);
      if (response.statusCode == 200) {
        return TestPackage.fromJson(response.data);
      } else {
        throw Exception('Failed to update package');
      }
    } catch (e) {
      throw Exception('Error updating package: $e');
    }
  }

  Future<void> deletePackage(String packageId) async {
    try {
      final response = await _dio.delete(ApiUrl.deletePackage(packageId));
      if (response.statusCode != 200) {
        throw Exception('Failed to delete package');
      }
    } catch (e) {
      throw Exception('Error deleting package: $e');
    }
  }
}
