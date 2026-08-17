import 'package:flutter/material.dart';

class PremiumCard extends StatelessWidget {
  const PremiumCard({super.key, required this.child, this.padding = const EdgeInsets.all(18), this.onTap, this.gradient});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? (isDark ? Colors.white.withValues(alpha: .055) : Colors.white) : null,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: .075) : const Color(0xFFE7ECF1)),
        boxShadow: isDark ? null : const [BoxShadow(color: Color(0x0D0F172A), blurRadius: 30, offset: Offset(0, 12))],
      ),
      child: child,
    );
    if (onTap == null) return content;
    return Material(color: Colors.transparent, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(24), child: content));
  }
}
