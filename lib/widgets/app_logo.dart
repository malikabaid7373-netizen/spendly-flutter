import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 48, this.showWordmark = true});
  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * .32),
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppPalette.mint, AppPalette.emerald, AppPalette.cyan]),
            boxShadow: [BoxShadow(color: AppPalette.emerald.withValues(alpha: .24), blurRadius: 24, offset: const Offset(0, 8))],
          ),
          child: Icon(Icons.ssid_chart_rounded, color: AppPalette.navy, size: size * .52),
        ),
        if (showWordmark) ...[
          const SizedBox(width: 12),
          Text.rich(
            TextSpan(children: [
              TextSpan(text: 'Spend', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const TextSpan(text: 'ly', style: TextStyle(color: AppPalette.emerald, fontWeight: FontWeight.w900)),
            ]),
          ),
        ],
      ],
    );
  }
}
