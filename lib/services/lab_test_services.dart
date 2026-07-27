import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../models/core_lab_test.dart';
import 'api_url.dart';

import '../models/my_lab_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LabTestServices {
  final Dio _dio = Dio();
  static const String _tokenKey = 'jwt_access_token';

  Future<String?> _getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

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

  Future<List<CoreLabTest>> getAllCoreTests({int page = 1, int limit = 20}) async {
    try {
      final int offset = (page - 1) * limit;
      final String query = '''
        query {
          getAllGlobalTests(limit: $limit, offset: $offset) {
            testId
            testName
            category
            description
            isProfile
            numberOfParameters
            sampleType
            searchTags
            fastingRequired
            fastingHours
            preTestInfo
          }
        }
      ''';

      final response = await _dio.post(
        ApiUrl.graphql,
        data: {'query': query},
      );

      if (response.statusCode == 200) {
        final List data = response.data['data']['getAllGlobalTests'];
        return data.map((json) => CoreLabTest.fromJson(_convertToSnakeCase(json))).toList();
      } else {
        throw Exception('Failed to load core lab tests');
      }
    } catch (e) {
      throw Exception('Error fetching core lab tests: $e');
    }
  }

  // Helper method since GraphQL returns camelCase, but models expect snake_case
  Map<String, dynamic> _convertToSnakeCase(Map<String, dynamic> json) {
    return {
      'test_id': json['testId'],
      'test_name': json['testName'],
      'category': json['category'],
      'description': json['description'],
      'is_profile': json['isProfile'],
      'number_of_parameters': json['numberOfParameters'],
      'sample_type': json['sampleType'],
      'search_tags': json['searchTags'],
      'fasting_required': json['fastingRequired'],
      'fasting_hours': json['fastingHours'],
      'pre_test_info': json['preTestInfo'],
      'price': json['price'],
      'discount_percentage': json['discountPercentage'],
      'final_price': json['finalPrice'],
      'lab_id': json['labId']
    };
  }

  Future<List<CoreLabTest>> searchCoreTests({String? name, String? category, int skip = 0, int limit = 20}) async {
    try {
      final String searchQuery = name ?? '';
      final String query = '''
        query {
          searchLabTests(query: "$searchQuery", limit: $limit, offset: $skip) {
            testId
            testName
            category
            description
            isProfile
            numberOfParameters
            sampleType
            searchTags
            fastingRequired
            fastingHours
            preTestInfo
          }
        }
      ''';

      final response = await _dio.post(
        ApiUrl.graphql,
        data: {'query': query},
      );

      if (response.statusCode == 200) {
        final List data = response.data['data']['searchLabTests'];
        return data.map((json) => CoreLabTest.fromJson(_convertToSnakeCase(json))).toList();
      } else {
        throw Exception('Failed to search core lab tests');
      }
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? e.message ?? 'Unknown error occurred';
      throw Exception(message);
    } catch (e) {
      throw Exception('Error searching core lab tests: $e');
    }
  }

  Future<CoreLabTest> getCoreTestById(String testId) async {
    try {
      final String query = '''
        query {
          getCoreTestById(testId: "$testId") {
            testId
            testName
            category
            description
            isProfile
            numberOfParameters
            sampleType
            searchTags
            fastingRequired
            fastingHours
            preTestInfo
          }
        }
      ''';

      final response = await _dio.post(
        ApiUrl.graphql,
        data: {'query': query},
      );

      if (response.statusCode == 200) {
        final data = response.data['data']['getCoreTestById'];
        return CoreLabTest.fromJson(_convertToSnakeCase(data));
      } else {
        throw Exception('Failed to load test details');
      }
    } catch (e) {
      throw Exception('Error fetching test details: $e');
    }
  }

  // Inventory Methods
  Future<MyLabTest> createInventory(String labId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiUrl.createInventory(labId), data: data);
      if (response.statusCode == 200) {
        return MyLabTest.fromJson(response.data);
      } else {
        throw Exception('Failed to create inventory');
      }
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? e.message ?? 'Unknown error occurred';
      throw Exception(message);
    } catch (e) {
      throw Exception('Error creating inventory: $e');
    }
  }

  Future<List<MyLabTest>> getInventoryByLab(String labId, {int page = 1, int limit = 20}) async {
    try {
      final int offset = (page - 1) * limit;
      final String query = '''
        query {
          getLabInventory(labId: "$labId", limit: $limit, offset: $offset) {
            testId
            testName
            category
            description
            isProfile
            numberOfParameters
            sampleType
            searchTags
            fastingRequired
            fastingHours
            preTestInfo
            price
            discountPercentage
            finalPrice
            labId
          }
        }
      ''';

      final response = await _dio.post(
        ApiUrl.graphql,
        data: {'query': query},
      );

      if (response.statusCode == 200) {
        final List data = response.data['data']['getLabInventory'];
        return data.map((json) => MyLabTest.fromJson(_convertToSnakeCase(json))).toList();
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

  Future<void> deleteInventory(String labId, List<String> testIds) async {
    try {
      final response = await _dio.post(
        ApiUrl.deleteInventory,
        data: {
          "test_ids": testIds,
          "lab_id": labId,
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to delete inventory items');
      }
    } catch (e) {
      throw Exception('Error deleting inventory: $e');
    }
  }
}
