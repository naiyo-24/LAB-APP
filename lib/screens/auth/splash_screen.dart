import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
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
    final List<IconData> medicalIcons = [
      IconsaxPlusLinear.microscope,
      IconsaxPlusLinear.hospital,
      IconsaxPlusLinear.health,
      IconsaxPlusLinear.activity,
      IconsaxPlusLinear.document_text,
      IconsaxPlusLinear.box,
      IconsaxPlusLinear.archive_add,
      IconsaxPlusLinear.heart,
      IconsaxPlusLinear.monitor,
      IconsaxPlusLinear.info_circle,
      IconsaxPlusLinear.call,
      IconsaxPlusLinear.sms,
      IconsaxPlusLinear.location,
      IconsaxPlusLinear.verify,
      IconsaxPlusLinear.receipt_text,
      IconsaxPlusLinear.money,
      IconsaxPlusLinear.percentage_square,
      IconsaxPlusLinear.wallet,
      IconsaxPlusLinear.clock,
      IconsaxPlusLinear.timer_1,
      IconsaxPlusLinear.truck,
      IconsaxPlusLinear.tick_circle,
      IconsaxPlusLinear.add_circle,
      IconsaxPlusLinear.calendar_tick,
      IconsaxPlusLinear.card_receive,
      IconsaxPlusLinear.notification,
    ];

    for (int i = 0; i < 40; i++) {
      _particles.add(
        Particle(
          position: Offset(_random.nextDouble(), _random.nextDouble()),
          size: _random.nextDouble() * 25 + 15,
          speed: _random.nextDouble() * 0.004 + 0.001,
          color: AppColors.primary.withAlpha(_random.nextInt(30) + 5),
          icon: medicalIcons[_random.nextInt(medicalIcons.length)],
        ),
      );
    }

    _handleInitialization();
  }

  Future<void> _handleInitialization() async {
    // Wait for splash animation (min 2.5s)
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    // Wait for auth state to finish loading if it's still busy
    while (ref.read(authProvider).isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
    }

    _performNavigation(ref.read(authProvider).user);
  }

  void _performNavigation(dynamic user) {
    if (user != null) {
      context.go('/profile');
    } else {
      context.go('/login');
    }
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
                    child: Transform.rotate(
                      angle: p.angle + (_particleController.value * 2 * pi),
                      child: Icon(p.icon, size: p.size, color: p.color),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          // Blur Effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.white.withAlpha(80),
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
                      width: 130,
                      height: 130,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          IconsaxPlusBold.health,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('MEDY24', style: AppTextStyles.header),
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
  IconData icon;
  Color color;
  double angle = Random().nextDouble() * 2 * pi;

  Particle({
    required this.position,
    required this.size,
    required this.speed,
    required this.color,
    required this.icon,
  });

  void update() {
    position = Offset(
      (position.dx + cos(angle) * speed) % 1.0,
      (position.dy + sin(angle) * speed) % 1.0,
    );
  }
}
