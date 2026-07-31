import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';
import 'providers/websocket_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: Medy24App(),
    ),
  );
}

class Medy24App extends ConsumerWidget {
  const Medy24App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Eagerly initialize and keep the WebSocket connected while the app is alive
    ref.watch(websocketServiceProvider);
    
    return MaterialApp.router(
      title: 'Medy24 Lab App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}
