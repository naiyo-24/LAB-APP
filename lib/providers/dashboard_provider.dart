import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/dashboard_data.dart';
import '../services/dashboard_service.dart';
import 'auth_provider.dart';
import 'profile_provider.dart';

final dashboardServiceProvider = Provider((ref) {
  final service = DashboardService();
  ref.onDispose(() => service.dispose());
  return service;
});

class DashboardState {
  final DashboardData? data;
  final bool isLoading;
  final String? error;

  DashboardState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    DashboardData? data,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final Ref _ref;
  final DashboardService _service;

  DashboardNotifier(this._ref, this._service) : super(DashboardState());

  Future<void> loadDashboard() async {
    final labId = _ref.read(authProvider).user?.id ?? _ref.read(profileProvider).user?.id;
    if (labId == null) {
      state = state.copyWith(error: 'Lab ID not found', isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await _service.fetchDashboardData(labId);
      state = state.copyWith(data: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final service = ref.read(dashboardServiceProvider);
  return DashboardNotifier(ref, service);
});
