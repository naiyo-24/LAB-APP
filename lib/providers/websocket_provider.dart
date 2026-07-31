import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/websocket_service.dart';
import 'auth_provider.dart';

final websocketServiceProvider = Provider<WebSocketService?>((ref) {
  final authState = ref.watch(authProvider);
  final labId = authState.user?.id ?? '';

  if (labId.isNotEmpty) {
    final service = WebSocketService(labId: labId, ref: ref);
    ref.onDispose(() {
      service.dispose();
    });
    return service;
  }
  return null;
});
