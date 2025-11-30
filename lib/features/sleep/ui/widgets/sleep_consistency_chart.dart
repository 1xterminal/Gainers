import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/sleep_model.dart';

class SleepConsistencyChart extends StatelessWidget {
  final List<SleepLog> weeklyLogs;
  final DateTime selectedDate;

  const SleepConsistencyChart({
    super.key,
    required this.weeklyLogs,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Reverting to Duration Chart as requested.
    // Y-axis: Hours of sleep.
    
    final end = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final start = end.subtract(const Duration(days: 6));
    
    List<BarChartGroupData> barGroups = [];
    double maxDuration = 0;

    for (int i = 0; i < 7; i++) {
      final day = start.add(Duration(days: i));
      
      // Find logs for this day (checking start_time)
      final logsForDay = weeklyLogs.where((log) {
        final logDate = DateTime(log.startTime.year, log.startTime.month, log.startTime.day);
        return DateUtils.isSameDay(logDate, day);
      });
      
      final totalMinutes = logsForDay.fold<int>(0, (sum, log) => sum + log.durationMinutes);
      final totalHours = totalMinutes / 60.0;
      
      if (totalHours > maxDuration) maxDuration = totalHours;

      final isSelected = DateUtils.isSameDay(day, selectedDate);
      
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: totalHours,
              color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFF8B5CF6).withValues(alpha: 0.3),
              width: 12,
              borderRadius: BorderRadius.circular(6),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 12, // Max expected sleep, e.g., 12 hours
                color: Colors.grey.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1.5,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 12, // Fixed max Y for consistency
          barTouchData: BarTouchData(
            enabled: false, // Disable touch for now as it's just visual
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= 7) return const SizedBox.shrink();
                  final day = start.add(Duration(days: index));
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('d').format(day),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: DateUtils.isSameDay(day, selectedDate) ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
