import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../notifiers/about_us_notifier.dart';
import '../services/about_us_services.dart';

final aboutUsServicesProvider = Provider<AboutUsServices>((ref) {
  return AboutUsServices();
});

final aboutUsProvider = StateNotifierProvider<AboutUsNotifier, AboutUsState>((ref) {
  final services = ref.watch(aboutUsServicesProvider);
  return AboutUsNotifier(services);
});
