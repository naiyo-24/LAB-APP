import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../models/core_lab_test.dart';
import 'api_url.dart';

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
}
