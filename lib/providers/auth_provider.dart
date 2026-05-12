import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../notifiers/auth_notifier.dart';
import '../services/auth_services.dart';

final authServicesProvider = Provider<AuthServices>((ref) {
  return AuthServices();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authServices = ref.watch(authServicesProvider);
  return AuthNotifier(authServices);
});
