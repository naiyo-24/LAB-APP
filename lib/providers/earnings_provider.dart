import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/earning.dart';
import '../models/earning_summary.dart';
import '../services/earnings_service.dart';
import 'profile_provider.dart';
import 'auth_provider.dart';

final earningsServiceProvider = Provider((ref) {
  final service = EarningsService();
  ref.onDispose(() => service.dispose());
  return service;
});

class EarningsState {
  final List<Earning> earnings;
  final EarningSummary? summary;
  final bool isLoading;
  final String? error;

  EarningsState({
    this.earnings = const [],
    this.summary,
    this.isLoading = false,
    this.error,
  });

  EarningsState copyWith({
    List<Earning>? earnings,
    EarningSummary? summary,
    bool? isLoading,
    String? error,
  }) {
    return EarningsState(
      earnings: earnings ?? this.earnings,
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class EarningsNotifier extends StateNotifier<EarningsState> {
  final Ref _ref;
  final EarningsService _service;

  EarningsNotifier(this._ref, this._service) : super(EarningsState());

  Future<void> loadEarnings() async {
    final labId = _ref.read(authProvider).user?.id ?? _ref.read(profileProvider).user?.id;
    if (labId == null) {
      state = state.copyWith(error: 'Lab ID not found', isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final results = await Future.wait([
        _service.fetchEarnings(labId),
        _service.fetchEarningsSummary(labId),
      ]);
      
      final earningsList = results[0] as List<Earning>;
      final summary = results[1] as EarningSummary;

      state = state.copyWith(
        earnings: earningsList,
        summary: summary,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final earningsProvider = StateNotifierProvider<EarningsNotifier, EarningsState>((ref) {
  final service = ref.read(earningsServiceProvider);
  return EarningsNotifier(ref, service);
});
