import 'package:flutter/material.dart';

class AnimatedProgressBar extends StatelessWidget {
  const AnimatedProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 8,
    this.backgroundColor,
  });

  final double value;
  final Color color;
  final double height;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0, 1).toDouble()),
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: LinearProgressIndicator(
            value: animatedValue,
            minHeight: height,
            backgroundColor: backgroundColor ?? Theme.of(context).dividerColor,
            color: color,
          ),
        );
      },
    );
  }
}
