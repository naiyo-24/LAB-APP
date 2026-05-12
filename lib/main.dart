import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: Medy24App(),
    ),
  );
}

class Medy24App extends StatelessWidget {
  const Medy24App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Medy24 Lab App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}
