import 'package:flutter_riverpod/legacy.dart';
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

  AuthNotifier(this._authServices) : super(AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authServices.login(email, password);
      if (response.statusCode == 200) {
        final userData = response.data['user'];
        state = state.copyWith(isLoading: false, user: User.fromJson(userData));
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['detail'] ?? "Login failed",
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
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
        state = state.copyWith(
          isLoading: false,
          user: User.fromJson({...fields, 'lab_id': response.data['lab_id']}),
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['detail'] ?? "Signup failed",
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setUser(User user) {
    state = state.copyWith(user: user);
  }

  void logout() {
    state = AuthState();
  }
}
