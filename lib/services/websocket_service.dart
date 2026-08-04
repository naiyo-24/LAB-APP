import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/order.dart';
import '../widgets/incoming_order_popup.dart';
import '../routes/app_router.dart';
import '../providers/order_provider.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final String labId;
  final Ref ref;
  bool _isDisposed = false;

  WebSocketService({required this.labId, required this.ref}) {
    _connect();
  }

  void _connect() {
    if (labId.isEmpty || _isDisposed) return;

    final wsUrl = Uri.parse('ws://192.168.0.222:8000/ws/labs/$labId');
    _channel = WebSocketChannel.connect(wsUrl);

    _channel!.stream.listen(
      (message) {
        try {
          final data = jsonDecode(message);
          if (data['type'] == 'NEW_LAB_BOOKING') {
            final orderData = data['booking'];
            final order = Order.fromJson(orderData);
            
            // Refresh order list immediately in the background
            ref.read(orderNotifierProvider.notifier).fetchOrders();

            // Show the popup
            final context = AppRouter.navigatorKey.currentContext;
            if (context != null) {
              // ignore: use_build_context_synchronously
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => IncomingOrderPopup(order: order),
              );
            }
          }
        } catch (e) {
          debugPrint('Error parsing websocket message: $e');
        }
      },
      onDone: () {
        if (_isDisposed) return;
        debugPrint('WebSocket closed, attempting reconnect...');
        Future.delayed(const Duration(seconds: 5), _connect);
      },
      onError: (error) {
        debugPrint('WebSocket error: $error');
      },
    );
  }

  void dispose() {
    _isDisposed = true;
    _channel?.sink.close();
  }
}
