import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color? backgroundColor;

  const DashboardCard({
    super.key,
    required this.child,
    this.onTap,
    this.gradient,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            (gradient == null ? theme.cardTheme.color : null),
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (gradient != null ? theme.primaryColor : Colors.black)
                .withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(padding: const EdgeInsets.all(20), child: child),
        ),
      ),
    );
  }
}
