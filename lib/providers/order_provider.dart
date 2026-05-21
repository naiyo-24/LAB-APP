import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/order_services.dart';
import '../notifiers/order_notifier.dart';
import 'auth_provider.dart';

final orderServicesProvider = Provider<OrderServices>((ref) {
  return OrderServices();
});

final orderNotifierProvider = StateNotifierProvider<OrderNotifier, OrderState>((
  ref,
) {
  final orderServices = ref.watch(orderServicesProvider);
  final authState = ref.watch(authProvider);
  final labId = authState.user?.id ?? '';

  return OrderNotifier(orderServices, labId);
});
