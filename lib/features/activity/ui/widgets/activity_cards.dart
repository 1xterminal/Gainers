import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gainers/core/theme/app_theme.dart';

class ActivityCards {
  //widget to make single info card
  static Widget buildSingleInfoCard(
    BuildContext context, {
    required int steps,
    required double distance,
    required double calories,
  }) {
    final theme = Theme.of(context).extension<BarChartTheme>()!;
    final double progress = (steps / 10000).clamp(0, 1);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.gridColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withValues(alpha: 0.2),
            offset: const Offset(0, 0),
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${NumberFormat('#,###').format(steps)} / 10,000 Steps',
            key: ValueKey<int>(steps),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.labelStyle.color,
            ),
          ),
          const SizedBox(height: 12),

          //progress bar with animations
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            tween: Tween<double>(begin: 0, end: progress),
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                backgroundColor: theme.barBackgroundColor,
                color: steps / 10000 >= 1
                    ? theme.toolTipColor.withBlue(70)
                    : theme.barColor,
                minHeight: 30,
                borderRadius: BorderRadius.circular(12),
              );
            },
          ),
          const SizedBox(height: 12),

          //distance and calories
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(Icons.map, color: theme.labelStyle.color),
                  const SizedBox(width: 8),
                  Text(
                    '${NumberFormat('#,##').format(distance)} km',
                    style: TextStyle(color: theme.labelStyle.color),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: theme.labelStyle.color,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${NumberFormat('###').format(calories)} cal',
                    style: TextStyle(color: theme.labelStyle.color),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  //widget to make double info card
  static Widget buildDoubleInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color cardColor,
    required Color textColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blueGrey.withValues(alpha: 0.2),
              offset: const Offset(0, 2),
              blurRadius: 5,
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: textColor, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  //widget to make lifetime info card
  static Widget buildLifetimeInfoCard(
    BuildContext context, {
    required String title,
    required int steps,
    required double distance,
    required Color textColor,
  }) {
    final theme = Theme.of(context).extension<BarChartTheme>()!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.gridColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withValues(alpha: 0.2),
            offset: const Offset(0, 0),
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assist_walker, color: textColor, size: 30),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          Divider(color: textColor, height: 20, thickness: 2),
          const SizedBox(height: 10),

          //steps and distance
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(Icons.map, color: textColor, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${NumberFormat('###').format(steps)} Steps',
                    style: TextStyle(color: textColor, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  Icon(Icons.directions_walk, color: textColor, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${NumberFormat('#,##').format(distance)} km',
                    style: TextStyle(color: textColor, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
    );
  }

  //widget to make record info card
  static Widget buildRecordInfoCard(
    BuildContext context, {
    required String title,
    required String title2,
    required int steps,
    required double distance,
    required Color textColor,
    DateTime? date,
  }) {
    final theme = Theme.of(context).extension<BarChartTheme>()!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.gridColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withValues(alpha: 0.2),
            offset: const Offset(0, 0),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, color: textColor, size: 30),
              const SizedBox(width: 12),
              Column(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    title2,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
            ],
          ),
          Container(height: 60, width: 2, color: textColor),
          const SizedBox(width: 24),

          //steps and distance
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (date != null) ...[
                Row(
                  children: [
                    Icon(Icons.calendar_month, color: textColor, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('dd/MM/yyyy').format(date),
                      style: TextStyle(color: textColor, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
              ],

              Row(
                children: [
                  Icon(Icons.map, color: textColor, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    '${NumberFormat('###').format(steps)} Steps',
                    style: TextStyle(color: textColor, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  Icon(Icons.directions_walk, color: textColor, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    '${NumberFormat('#,##').format(distance)} km',
                    style: TextStyle(color: textColor, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
    );
  }
}
