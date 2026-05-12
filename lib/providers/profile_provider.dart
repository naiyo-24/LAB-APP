import 'package:flutter_riverpod/legacy.dart';
import '../notifiers/profile_notifier.dart';
import 'auth_provider.dart';

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((
  ref,
) {
  final authServices = ref.watch(authServicesProvider);
  return ProfileNotifier(authServices, ref);
});
