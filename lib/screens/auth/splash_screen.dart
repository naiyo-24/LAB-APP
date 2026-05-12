import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Initialize random particles
    for (int i = 0; i < 15; i++) {
      _particles.add(Particle(
        position: Offset(_random.nextDouble(), _random.nextDouble()),
        size: _random.nextDouble() * 100 + 50,
        speed: _random.nextDouble() * 0.02 + 0.01,
        color: AppColors.primary.withOpacity(_random.nextDouble() * 0.3),
      ));
    }

    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Animations
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return Stack(
                children: _particles.map((p) {
                  p.update();
                  return Positioned(
                    left: p.position.dx * MediaQuery.of(context).size.width,
                    top: p.position.dy * MediaQuery.of(context).size.height,
                    child: Container(
                      width: p.size,
                      height: p.size,
                      decoration: BoxDecoration(
                        color: p.color,
                        shape: BoxShape.circle,
                      ),
                      child: const Opacity(
                        opacity: 0.5,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          // Blur Effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ColorFilter.mode(
                Colors.white.withOpacity(0.4),
                BlendMode.overlay,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
            ),
          ),
          // Center Content
          Center(
            child: FadeTransition(
              opacity: _mainController,
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: _mainController,
                  curve: Curves.elasticOut,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo/logo.png',
                      width: 120,
                      height: 120,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(IconsaxPlusBold.health, size: 60, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'MEDY24',
                      style: AppTextStyles.header,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your Health, Our Priority',
                      style: AppTextStyles.tagline,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Particle {
  Offset position;
  double size;
  double speed;
  Color color;
  double angle = Random().nextDouble() * 2 * pi;

  Particle({
    required this.position,
    required this.size,
    required this.speed,
    required this.color,
  });

  void update() {
    position = Offset(
      (position.dx + cos(angle) * speed) % 1.0,
      (position.dy + sin(angle) * speed) % 1.0,
    );
  }
}
