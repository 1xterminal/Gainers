import 'package:flutter/material.dart';

class AnimatedCounter extends StatelessWidget {
  final num value;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final Duration duration;
  final Curve curve;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeOutExpo,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<num>(
      tween: Tween<num>(begin: 0, end: value),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        // Determine if we should show as int or double based on input type
        final formattedValue = this.value is int
            ? value.toInt().toString()
            : value.toStringAsFixed(1);

        return Text('$prefix$formattedValue$suffix', style: style);
      },
    );
  }
}
