import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../services/auth_services.dart';

class ProfileState {
  final User? user;
  final bool isLoading;
  final String? error;

  ProfileState({this.user, this.isLoading = false, this.error});

  ProfileState copyWith({User? user, bool? isLoading, String? error}) {
    return ProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final AuthServices _authServices;
  final Ref _ref;

  ProfileNotifier(this._authServices, this._ref) : super(ProfileState());

  Future<void> fetchProfile(String labId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authServices.getProfile(labId);
      if (response.statusCode == 200) {
        final user = User.fromJson(response.data);
        state = state.copyWith(isLoading: false, user: user);
        // Sync with AuthProvider
        _ref.read(authProvider.notifier).setUser(user);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['detail'] ?? "Failed to fetch profile",
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setUser(User user) {
    state = state.copyWith(user: user);
  }

  Future<void> updateProfile(
    User updatedUser, {
    String? labLogoFile,
    String? regCertFile,
    String? bankPassbookFile,
  }) async {
    if (updatedUser.id == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final fields = {
        'lab_name': updatedUser.labName,
        'mobile_number': updatedUser.mobileNumber,
        'email_address': updatedUser.email,
        'address': updatedUser.address,
        'pan_number': updatedUser.panNumber,
        'nabl_accreditation_number': updatedUser.nablNumber,
        'gst_number': updatedUser.gstNumber,
        'emergency_contact_number': updatedUser.emergencyContact,
        'whatsapp_number': updatedUser.whatsappNumber,
      };

      final response = await _authServices.updateProfile(
        updatedUser.id!,
        fields: fields,
        labLogoPath: labLogoFile,
        regCertPath: regCertFile,
        bankPassbookPath: bankPassbookFile,
      );

      if (response.statusCode == 200) {
        final updatedUserWithResponse = User.fromJson(response.data);
        state = state.copyWith(isLoading: false, user: updatedUserWithResponse);
        // Sync with AuthProvider
        _ref.read(authProvider.notifier).setUser(updatedUserWithResponse);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['detail'] ?? "Update failed",
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
