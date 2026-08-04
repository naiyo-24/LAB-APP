import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../models/dashboard_data.dart';
import 'api_url.dart';

class DashboardService {
  late Dio _dio;

  DashboardService() {
    _dio = Dio();
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: true,
    ));
  }

  Future<DashboardData> fetchDashboardData(String labId) async {
    try {
      final response = await _dio.get(ApiUrl.getDashboardAnalytics(labId));
      return DashboardData.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch dashboard data: $e');
    }
  }

  void dispose() {
    _dio.close();
  }
}
