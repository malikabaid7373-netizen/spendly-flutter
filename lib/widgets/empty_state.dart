import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.body, this.actionLabel, this.onAction});
  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 34),
      child: Column(children: [
        Container(width: 72, height: 72, decoration: BoxDecoration(color: AppPalette.emerald.withValues(alpha: .12), shape: BoxShape.circle), child: Icon(icon, color: AppPalette.emerald, size: 30)),
        const SizedBox(height: 18),
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text(body, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor, height: 1.55)),
        if (actionLabel != null) ...[const SizedBox(height: 18), FilledButton(onPressed: onAction, child: Text(actionLabel!))],
      ]),
    );
  }
}
