import 'package:flutter_riverpod/legacy.dart';
import 'package:dio/dio.dart';
import '../models/user.dart';
import '../services/auth_services.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthServices _authServices;

  AuthNotifier(this._authServices) : super(AuthState(isLoading: true)) {
    loadSession();
  }

  Future<void> loadSession() async {
    try {
      final savedId = await _authServices.getSavedLabId();
      if (savedId != null) {
        final response = await _authServices.getProfile(savedId);
        final user = User.fromJson(response.data);
        state = state.copyWith(user: user);
      }
    } catch (e) {
      // Log error if needed
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> login(String phone, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authServices.login(phone, password);
      if (response.statusCode == 200) {
        final accessToken = response.data['access_token'];
        final userId = response.data['user_id'];
        
        // Save session with JWT token
        if (userId != null && accessToken != null) {
          await _authServices.saveLabIdAndToken(userId, accessToken);
        }
        
        // Since the new backend doesn't return full user details on login,
        // we might create a dummy user or fetch profile later.
        final user = User(id: userId, labName: "Lab User", mobileNumber: phone);
        state = state.copyWith(isLoading: false, user: user);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['detail'] ?? "Login failed",
        );
      }
    } catch (e) {
      String errorMessage = "Login failed";
      if (e is DioException && e.response?.data is Map) {
        errorMessage = e.response?.data['detail'] ?? errorMessage;
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  Future<void> signup({
    required Map<String, dynamic> data,
    required List<String> filePaths,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Re-map keys to match backend Form expectations
      final fields = {
        'lab_name': data['lab_name'],
        'mobile_number': data['mobile_number'],
        'email_address': data['email_address'],
        'password': data['password'],
        'pan_number': data['pan_number'],
        'nabl_accreditation_number': data['nabl_accreditation_number'],
        'address': data['address'],
        'terms_conditions_accepted': data['terms_conditions_accepted'],
        'privacy_policy_accepted': data['privacy_policy_accepted'],
        'gst_number': data['gst_number'],
        'emergency_contact_number': data['emergency_contact_number'],
        'whatsapp_number': data['whatsapp_number'],
      };

      final response = await _authServices.signupMultipart(
        fields: fields,
        labLogoPath: data['lab_logo_path'],
        regCertPath: data['registration_certificate_path'],
        bankPassbookPath: data['bank_passbook_path'],
      );

      if (response.statusCode == 200) {
        final labId = response.data['lab_id'];
        final user = User.fromJson({...fields, 'lab_id': labId});
        
        // Save session
        // Note: New backend might not return a token during registration, or returns it differently.
        // Assuming we just save the lab ID for now, or redirect to login.
        // Let's create a temporary token or require login afterwards.
        if (user.id != null) {
          await _authServices.saveLabIdAndToken(user.id!, ""); 
        }
        
        state = state.copyWith(isLoading: false, user: user);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['detail'] ?? "Signup failed",
        );
      }
    } catch (e) {
      String errorMessage = "Signup failed";
      if (e is DioException && e.response?.data is Map) {
        errorMessage = e.response?.data['detail'] ?? errorMessage;
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  void setUser(User user) {
    state = state.copyWith(user: user);
  }

  Future<void> logout() async {
    await _authServices.clearSession();
    state = AuthState();
  }
}
