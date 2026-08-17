import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../view_models/app_settings_view_model.dart';
import '../../widgets/animated_reveal.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/premium_card.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppPalette.cyan.withValues(alpha: isDark ? .07 : .10),
              ),
            ),
          ),
          Positioned(
            bottom: -130,
            left: -90,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppPalette.emerald.withValues(alpha: isDark ? .06 : .09),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AnimatedReveal(
                        child: Row(
                          children: [
                            const AppLogo(size: 42),
                            const Spacer(),
                            _MiniButton(
                              icon: Icons.language_rounded,
                              label: settings.locale.languageCode == 'en'
                                  ? 'AR'
                                  : 'EN',
                              onTap: () => settings.setLocale(
                                Locale(
                                  settings.locale.languageCode == 'en'
                                      ? 'ar'
                                      : 'en',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _MiniButton(
                              icon: settings.themeMode == ThemeMode.dark
                                  ? Icons.light_mode_rounded
                                  : Icons.dark_mode_rounded,
                              onTap: settings.toggleTheme,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 34),
                      AnimatedReveal(
                        delay: const Duration(milliseconds: 90),
                        child: PremiumCard(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: children,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      AnimatedReveal(
                        delay: const Duration(milliseconds: 160),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 14,
                              color: Theme.of(context).hintColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              context.t('localPrivate'),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).hintColor,
                                    fontSize: 10,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  const _MiniButton({required this.icon, required this.onTap, this.label});

  final IconData icon;
  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: .75),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            if (label != null) ...[
              const SizedBox(width: 6),
              Text(
                label!,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
