import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../models/earning.dart';
import '../models/earning_summary.dart';
import 'api_url.dart';

class EarningsService {
  late Dio _dio;

  EarningsService() {
    _dio = Dio();
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: true,
    ));
  }

  Future<List<Earning>> fetchEarnings(String labId) async {
    try {
      final response = await _dio.get(ApiUrl.getEarnings(labId));
      return (response.data as List).map((e) => Earning.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch earnings: $e');
    }
  }

  Future<EarningSummary> fetchEarningsSummary(String labId) async {
    try {
      final response = await _dio.get(ApiUrl.getEarningsSummary(labId));
      return EarningSummary.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch earnings summary: $e');
    }
  }

  void dispose() {
    _dio.close();
  }
}
