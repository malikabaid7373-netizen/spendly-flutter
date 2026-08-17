import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/i18n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../view_models/app_settings_view_model.dart';
import '../../view_models/finance_view_model.dart';
import '../../widgets/animated_reveal.dart';
import '../../widgets/premium_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsViewModel>();
    final finance = context.watch<FinanceViewModel>();
    final profile = settings.profile;
    final isDark = settings.themeMode == ThemeMode.dark;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
        children: [
          AnimatedReveal(
            child: Text(
              context.t('profile'),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedReveal(
            delay: const Duration(milliseconds: 60),
            child: PremiumCard(
              padding: EdgeInsets.zero,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF12382F), Color(0xFF10243A)],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -48,
                    right: -36,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppPalette.cyan.withOpacity(.08),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Hero(
                              tag: 'profile-avatar',
                              child: CircleAvatar(
                                radius: 31,
                                backgroundColor: AppPalette.emerald,
                                child: Text(
                                  profile?.initials ?? 'A',
                                  style: const TextStyle(
                                    color: AppPalette.navy,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile?.name ?? 'Abaid',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 19,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    profile?.email ?? 'abaid@spendly.app',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFFA8BBBF),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.07),
                            borderRadius: BorderRadius.circular(17),
                            border: Border.all(
                              color: Colors.white.withOpacity(.08),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: AppPalette.emerald.withOpacity(.14),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.workspace_premium_rounded,
                                  color: AppPalette.mint,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  context.t('portfolioMode'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _ProfileStat(
                                value: '${finance.transactions.length}',
                                label: context.t('transactionsCount'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _ProfileStat(
                                value: '${finance.activeBudgetCount}',
                                label: context.t('activeBudgets'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _ProfileStat(
                                value: '${finance.financialHealthScore}/100',
                                label: context.t('financialScore'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            context.t('settings'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          AnimatedReveal(
            delay: const Duration(milliseconds: 100),
            child: PremiumCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsRow(
                    icon: Icons.dark_mode_rounded,
                    iconColor: AppPalette.cyan,
                    iconBackground: AppPalette.cyan.withOpacity(.10),
                    title: context.t('darkMode'),
                    subtitle: context.t('appearance'),
                    trailing: _ThemeToggle(
                      isDark: isDark,
                      onChanged: () {
                        settings.toggleTheme();
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingsRow(
                    icon: Icons.language_rounded,
                    iconColor: AppPalette.emerald,
                    iconBackground: AppPalette.emerald.withOpacity(.10),
                    title: context.t('language'),
                    subtitle: settings.locale.languageCode == 'ar'
                        ? context.t('arabic')
                        : context.t('english'),
                    trailing: _LanguageSelector(
                      selectedCode: settings.locale.languageCode,
                      onChanged: (String code) {
                        settings.setLocale(Locale(code));
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingsRow(
                    icon: Icons.currency_exchange_rounded,
                    iconColor: AppPalette.warning,
                    iconBackground: AppPalette.warning.withOpacity(.10),
                    title: context.t('currency'),
                    subtitle: context.t('sar'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        'SAR',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          AnimatedReveal(
            delay: const Duration(milliseconds: 140),
            child: _ActionCard(
              icon: Icons.restore_rounded,
              iconColor: AppPalette.cyan,
              iconBackground: AppPalette.cyan.withOpacity(.10),
              title: context.t('resetDemo'),
              onTap: () async {
                await context.read<FinanceViewModel>().seedDemoData(force: true);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.t('resetDone'))),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          AnimatedReveal(
            delay: const Duration(milliseconds: 170),
            child: _ActionCard(
              icon: Icons.logout_rounded,
              iconColor: Theme.of(context).colorScheme.error,
              iconBackground:
              Theme.of(context).colorScheme.error.withOpacity(.10),
              title: context.t('logout'),
              titleColor: Theme.of(context).colorScheme.error,
              onTap: () async {
                await settings.logout();
                if (!context.mounted) return;
                context.go('/login');
              },
            ),
          ),
          const SizedBox(height: 18),
          AnimatedReveal(
            delay: const Duration(milliseconds: 200),
            child: PremiumCard(
              gradient: LinearGradient(
                colors: [
                  AppPalette.cyan.withOpacity(.10),
                  AppPalette.emerald.withOpacity(.05),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppPalette.cyan.withOpacity(.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppPalette.cyan,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.t('portfolioMode'),
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          context.t('portfolioModeBody'),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).hintColor,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.t('localOnlyBody'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.07),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white.withOpacity(.06)),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF91A7AA),
              fontSize: 9.5,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          trailing,
        ],
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle({required this.isDark, required this.onChanged});

  final bool isDark;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChanged,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 72,
        height: 38,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF17233A)
              : AppPalette.emerald.withOpacity(.10),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(.10)
                : AppPalette.emerald.withOpacity(.18),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 30,
                decoration: BoxDecoration(
                  color: isDark ? Colors.transparent : Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.light_mode_rounded,
                  size: 16,
                  color: isDark ? Colors.white38 : AppPalette.emerald,
                ),
              ),
            ),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 30,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF263752) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.dark_mode_rounded,
                  size: 16,
                  color: isDark ? const Color(0xFFFFD166) : Colors.black38,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({
    required this.selectedCode,
    required this.onChanged,
  });

  final String selectedCode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LanguageButton(
            label: 'EN',
            selected: selectedCode == 'en',
            onTap: () {
              onChanged('en');
            },
          ),
          _LanguageButton(
            label: 'AR',
            selected: selectedCode == 'ar',
            onTap: () {
              onChanged('ar');
            },
          ),
        ],
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        constraints: const BoxConstraints(minWidth: 42),
        height: 30,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          color: selected
              ? AppPalette.emerald.withOpacity(.16)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
            color: selected ? AppPalette.emerald : Theme.of(context).hintColor,
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    this.titleColor,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final Color? titleColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: titleColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
              color: titleColor ?? Theme.of(context).hintColor,
            ),
          ],
        ),
      ),
    );
  }
}
