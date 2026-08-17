import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../view_models/app_settings_view_model.dart';
import '../../widgets/animated_reveal.dart';
import '../../widgets/app_logo.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _items = [
    (
      Icons.account_balance_wallet_rounded,
      'onboarding1Title',
      'onboarding1Body',
      AppPalette.emerald,
    ),
    (
      Icons.track_changes_rounded,
      'onboarding2Title',
      'onboarding2Body',
      AppPalette.cyan,
    ),
    (
      Icons.auto_graph_rounded,
      'onboarding3Title',
      'onboarding3Body',
      AppPalette.warning,
    ),
  ];

  Future<void> _finish() async {
    await context.read<AppSettingsViewModel>().completeOnboarding();
    if (mounted) context.go('/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _items.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
          child: Column(
            children: [
              AnimatedReveal(
                child: Row(
                  children: [
                    const AppLogo(size: 42),
                    const Spacer(),
                    TextButton(
                      onPressed: _finish,
                      child: Text(context.t('skip')),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _items.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return _OnboardingPage(
                      key: ValueKey(index),
                      icon: item.$1,
                      title: context.t(item.$2),
                      body: context.t(item.$3),
                      color: item.$4,
                      index: index,
                    );
                  },
                ),
              ),
              Row(
                children: [
                  ...List.generate(
                    _items.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsetsDirectional.only(end: 7),
                      width: _index == index ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: _index == index
                            ? const LinearGradient(
                                colors: [AppPalette.emerald, AppPalette.cyan],
                              )
                            : null,
                        color: _index == index
                            ? null
                            : Theme.of(context).dividerColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () {
                      if (isLast) {
                        _finish();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 420),
                          curve: Curves.easeOutCubic,
                        );
                      }
                    },
                    icon: Icon(
                      isLast
                          ? Icons.check_rounded
                          : Icons.arrow_forward_rounded,
                    ),
                    label: Text(context.t(isLast ? 'getStarted' : 'next')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
    required this.index,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color color;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedReveal(
          child: Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF12362F), Color(0xFF0B2630), Color(0xFF10233A)],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: .14),
                  blurRadius: 36,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: -40,
                  right: -35,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: .10),
                    ),
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: .78, end: 1),
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) => Transform.scale(
                    scale: value,
                    child: child,
                  ),
                  child: Container(
                    width: 126,
                    height: 126,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          color.withValues(alpha: .28),
                          color.withValues(alpha: .04),
                        ],
                      ),
                      border: Border.all(color: color.withValues(alpha: .22)),
                    ),
                    child: Icon(icon, size: 66, color: color),
                  ),
                ),
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 22,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, AppPalette.cyan.withValues(alpha: .25)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                Positioned(
                  left: 22,
                  top: 22,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .07),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '0${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 34),
        AnimatedReveal(
          delay: const Duration(milliseconds: 90),
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.08,
                ),
          ),
        ),
        const SizedBox(height: 14),
        AnimatedReveal(
          delay: const Duration(milliseconds: 140),
          child: Text(
            body,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).hintColor,
                  height: 1.6,
                ),
          ),
        ),
      ],
    );
  }
}
