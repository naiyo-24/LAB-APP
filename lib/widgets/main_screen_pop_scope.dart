import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScreenPopScope extends StatelessWidget {
  final Widget child;
  
  const MainScreenPopScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        
        // If they press back, navigate back to the dashboard instead of closing the app
        context.go('/dashboard');
      },
      child: child,
    );
  }
}
