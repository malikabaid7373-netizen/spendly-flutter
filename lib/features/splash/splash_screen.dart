import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../view_models/app_settings_view_model.dart';
import '../../widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _pulseController;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _scale = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutBack,
    );
    _fade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(.08, 1, curve: Curves.easeOut),
    );
    _entryController.forward();
    _timer = Timer(const Duration(milliseconds: 1250), _continue);
  }

  void _continue() {
    if (!mounted) return;
    final settings = context.read<AppSettingsViewModel>();
    settings.finishSplash();

    if (!settings.onboardingCompleted) {
      context.go('/onboarding');
      return;
    }
    if (!settings.isSignedIn) {
      context.go('/login');
      return;
    }
    context.go('/home');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF07111F), Color(0xFF0A1A2B), Color(0xFF07111F)],
              ),
            ),
          ),
          Positioned(
            top: -110,
            right: -90,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppPalette.cyan.withValues(alpha: .08),
              ),
            ),
          ),
          Positioned(
            bottom: -140,
            left: -100,
            child: Container(
              width: 330,
              height: 330,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppPalette.emerald.withValues(alpha: .06),
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 126,
                      height: 126,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, _) {
                              final pulse = _pulseController.value;
                              return Container(
                                width: 94 + (pulse * 28),
                                height: 94 + (pulse * 28),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppPalette.emerald.withValues(
                                      alpha: .18 * (1 - pulse),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          RotationTransition(
                            turns: _pulseController,
                            child: Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppPalette.cyan.withValues(alpha: .16),
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppPalette.cyan,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const AppLogo(size: 72),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      context.t('tagline'),
                      style: const TextStyle(
                        color: Color(0xFFC2CEDB),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: 142,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          minHeight: 3,
                          backgroundColor: Colors.white.withValues(alpha: .08),
                          color: AppPalette.emerald,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 36,
            child: Text(
              context.t('splashCaption'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .42),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
