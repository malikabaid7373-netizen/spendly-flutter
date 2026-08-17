import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/i18n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../transactions/add_transaction_sheet.dart';

class MainShell extends StatelessWidget {
  const MainShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _navigate(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  Future<void> _add(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTransactionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 820;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedIndex = navigationShell.currentIndex;

    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: NavigationRail(
                    selectedIndex: selectedIndex,
                    onDestinationSelected: _navigate,
                    labelType: NavigationRailLabelType.all,
                    backgroundColor:
                        isDark ? const Color(0xFF0B1726) : Colors.white,
                    leading: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: _AddButton(
                        onTap: () => _add(context),
                        compact: true,
                      ),
                    ),
                    destinations: [
                      NavigationRailDestination(
                        icon: const Icon(Icons.home_outlined),
                        selectedIcon: const Icon(Icons.home_rounded),
                        label: Text(context.t('home')),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.receipt_long_outlined),
                        selectedIcon: const Icon(Icons.receipt_long_rounded),
                        label: Text(context.t('transactions')),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.track_changes_outlined),
                        selectedIcon: const Icon(Icons.track_changes_rounded),
                        label: Text(context.t('budgets')),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.bar_chart_outlined),
                        selectedIcon: const Icon(Icons.bar_chart_rounded),
                        label: Text(context.t('analytics')),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.person_outline_rounded),
                        selectedIcon: const Icon(Icons.person_rounded),
                        label: Text(context.t('profile')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      floatingActionButton: _AddButton(onTap: () => _add(context)),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              boxShadow: isDark
                  ? null
                  : const [
                      BoxShadow(
                        color: Color(0x160F172A),
                        blurRadius: 26,
                        offset: Offset(0, 12),
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: _navigate,
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.home_outlined),
                    selectedIcon: const Icon(Icons.home_rounded),
                    label: context.t('home'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.receipt_long_outlined),
                    selectedIcon: const Icon(Icons.receipt_long_rounded),
                    label: context.t('transactions'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.track_changes_outlined),
                    selectedIcon: const Icon(Icons.track_changes_rounded),
                    label: context.t('budgets'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.bar_chart_outlined),
                    selectedIcon: const Icon(Icons.bar_chart_rounded),
                    label: context.t('analytics'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.person_outline_rounded),
                    selectedIcon: const Icon(Icons.person_rounded),
                    label: context.t('profile'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatefulWidget {
  const _AddButton({required this.onTap, this.compact = false});

  final VoidCallback onTap;
  final bool compact;

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final size = widget.compact ? 46.0 : 58.0;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? .92 : 1,
        duration: const Duration(milliseconds: 100),
        child: RepaintBoundary(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppPalette.emerald, AppPalette.cyan],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppPalette.emerald.withValues(alpha: .26),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: const Icon(
              Icons.add_rounded,
              color: AppPalette.navy,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
