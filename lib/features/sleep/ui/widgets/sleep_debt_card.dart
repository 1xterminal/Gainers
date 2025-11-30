import 'package:flutter/material.dart';

class SleepDebtCard extends StatelessWidget {
  final double debtHours; // Positive = debt, Negative = surplus

  const SleepDebtCard({
    super.key,
    required this.debtHours,
  });

  @override
  Widget build(BuildContext context) {
    final isDebt = debtHours > 0;
    final absHours = debtHours.abs();
    final color = isDebt ? Colors.red : Colors.green;
    final icon = isDebt ? Icons.warning_amber_rounded : Icons.check_circle;
    final label = isDebt ? 'Sleep Debt' : 'Sleep Surplus';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                '(Last 7 days)',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                isDebt ? '-' : '+',
                style: TextStyle(
                  color: color,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: absHours),
                duration: const Duration(seconds: 1),
                curve: Curves.easeOutExpo,
                builder: (context, value, child) {
                  return Text(
                    value.toStringAsFixed(1),
                    style: TextStyle(
                      color: color,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
              Text(
                'hours',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isDebt
                ? 'You need more sleep to recover!'
                : 'Great job! You\'re well-rested.',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
