import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_url.dart';

class AuthServices {
  final Dio _dio = Dio();
  static const String _labIdKey = 'logged_in_lab_id';

  AuthServices() {
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _getPrefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Session Management
  Future<void> saveLabId(String labId) async {
    debugPrint('Saving session for labId: $labId');
    final prefs = await _getPrefs;
    await prefs.setString(_labIdKey, labId);
  }

  Future<String?> getSavedLabId() async {
    final prefs = await _getPrefs;
    final id = prefs.getString(_labIdKey);
    debugPrint('Retrieved saved labId: $id');
    return id;
  }

  Future<void> clearSession() async {
    debugPrint('Clearing session');
    final prefs = await _getPrefs;
    await prefs.remove(_labIdKey);
  }

  Future<Response> signup(
    Map<String, dynamic> data,
    List<String> filePaths,
  ) async {
    FormData formData = FormData.fromMap(data);

    // Specific files based on backend keys
    if (filePaths.isNotEmpty) {
      // Assuming order or finding by name if logic allows,
      // but here we map manually based on what we know from SignupScreen
      if (data.containsKey('lab_logo_path')) {
        formData.files.add(
          MapEntry(
            'lab_logo',
            await MultipartFile.fromFile(data['lab_logo_path']),
          ),
        );
      }
      // Re-mapping from data keys if available, or using positional if passed differently
      // In our signup screen we passed 'lab_logo', 'registration_certificate', 'bank_passbook'
    }

    return await _dio.post(ApiUrl.signup, data: formData);
  }

  // Improved signup that takes explicit files
  Future<Response> signupMultipart({
    required Map<String, dynamic> fields,
    String? labLogoPath,
    required String regCertPath,
    required String bankPassbookPath,
  }) async {
    FormData formData = FormData.fromMap(fields);

    if (labLogoPath != null) {
      formData.files.add(
        MapEntry('lab_logo', await MultipartFile.fromFile(labLogoPath)),
      );
    }
    formData.files.add(
      MapEntry(
        'registration_certificate',
        await MultipartFile.fromFile(regCertPath),
      ),
    );
    formData.files.add(
      MapEntry('bank_passbook', await MultipartFile.fromFile(bankPassbookPath)),
    );

    return await _dio.post(ApiUrl.signup, data: formData);
  }

  Future<Response> login(String email, String password) async {
    FormData formData = FormData.fromMap({
      'email': email,
      'password': password,
    });
    return await _dio.post(ApiUrl.login, data: formData);
  }

  Future<Response> getProfile(String labId) async {
    return await _dio.get(ApiUrl.profile(labId));
  }

  Future<Response> updateProfile(
    String labId, {
    Map<String, dynamic>? fields,
    String? labLogoPath,
    String? regCertPath,
    String? bankPassbookPath,
  }) async {
    FormData formData = FormData.fromMap(fields ?? {});

    if (labLogoPath != null) {
      formData.files.add(
        MapEntry('lab_logo', await MultipartFile.fromFile(labLogoPath)),
      );
    }
    if (regCertPath != null) {
      formData.files.add(
        MapEntry(
          'registration_certificate',
          await MultipartFile.fromFile(regCertPath),
        ),
      );
    }
    if (bankPassbookPath != null) {
      formData.files.add(
        MapEntry(
          'bank_passbook',
          await MultipartFile.fromFile(bankPassbookPath),
        ),
      );
    }

    return await _dio.put(ApiUrl.updateProfile(labId), data: formData);
  }
}
