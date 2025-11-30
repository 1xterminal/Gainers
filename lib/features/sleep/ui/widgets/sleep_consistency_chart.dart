import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
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
    final end = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final start = end.subtract(const Duration(days: 6));

    // Prepare data for the chart
    List<_ChartData> chartData = [];
    for (int i = 0; i < 7; i++) {
      final day = start.add(Duration(days: i));

      // Find logs for this day
      final logsForDay = weeklyLogs.where((log) {
        final logDate = DateTime(
          log.startTime.year,
          log.startTime.month,
          log.startTime.day,
        );
        return DateUtils.isSameDay(logDate, day);
      });

      final totalMinutes = logsForDay.fold<int>(
        0,
        (sum, log) => sum + log.durationMinutes,
      );
      final totalHours = totalMinutes / 60.0;

      chartData.add(_ChartData(day, totalHours));
    }

    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: DateTimeAxis(
        majorGridLines: const MajorGridLines(width: 0),
        intervalType: DateTimeIntervalType.days,
        interval: 1,
        dateFormat: DateFormat('d'),
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        minimum: start,
        maximum: end,
      ),
      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum: 12, // Assuming 12 hours max for better scale
        interval: 3,
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        header: '',
        format: 'point.y h',
      ),
      series: <CartesianSeries<_ChartData, DateTime>>[
        SplineSeries<_ChartData, DateTime>(
          dataSource: chartData,
          xValueMapper: (_ChartData data, _) => data.date,
          yValueMapper: (_ChartData data, _) => data.hours,
          color: theme.primaryColor,
          width: 4,
          markerSettings: const MarkerSettings(isVisible: true),
          name: 'Sleep',
        ),
      ],
    );
  }
}

class _ChartData {
  final DateTime date;
  final double hours;

  _ChartData(this.date, this.hours);
}
