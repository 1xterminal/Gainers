import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gainers/features/activity/data/models/step_data.dart';
import 'package:gainers/features/activity/providers/activity_details_provider.dart';

class ActivityDetailsScreen extends ConsumerWidget {
  const ActivityDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncHealthState = ref.watch(healthProvider);

    return asyncHealthState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),

      error: (e, stack) {
        final errorText = e.toString();
        final isPermissionDenied = errorText.contains('Permanently Denied!');

        return Scaffold(
          appBar: AppBar(title: const Text('Activity Details')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isPermissionDenied
                        ? 'Permission Required'
                        : 'Could Not Load Activity Details',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    e.toString().replaceAll('Exception:', ''),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  if (isPermissionDenied)
                    ElevatedButton(
                      onPressed: () => openAppSettings(),
                      child: const Text('Open Settings'),
                    ),
                ],
              ),
            ),
          ),
        );
      },

      data: (healthStats) {
        final lastSevenDays = healthStats.weeklyData;
        final stepsToday = healthStats.todaysSteps;

        final int totalStepsSeven = lastSevenDays.fold(
          0,
          (sum, item) => sum + item.steps,
        );
        final double totalDistanceToday = stepsToday * 0.0003048;
        final double totalDistanceSeven = totalStepsSeven * 0.0003048;

        return Scaffold(
          appBar: AppBar(title: const Text('Activity Details')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 40, left: 13, right: 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Last 7 Days',
                  style: TextStyle(
                    color: Colors.lightBlue.shade800,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                Container(
                  height: 290,
                  padding: const EdgeInsets.only(right: 16, left: 16, top: 10),
                  child: _buildBarChart(lastSevenDays),
                ),
                const SizedBox(height: 40),

                Text(
                  'Today\'s Stats',
                  style: TextStyle(
                    color: Colors.lightBlue.shade800,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    _buildInfoCard(
                      title: 'Total Steps',
                      value: NumberFormat('#,###').format(stepsToday),
                      icon: Icons.directions_run,
                      color: Colors.lightBlue.shade800,
                    ),
                    const SizedBox(width: 16),
                    _buildInfoCard(
                      title: 'Total Distance (km)',
                      value: NumberFormat('#,###').format(totalDistanceToday),
                      icon: Icons.arrow_circle_right_outlined,
                      color: Colors.lightBlue.shade800,
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                Text(
                  'Lifetime Stats',
                  style: TextStyle(
                    color: Colors.lightBlue.shade800,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    _buildInfoCard(
                      title: 'Total Steps',
                      value: NumberFormat('#,###').format(totalStepsSeven),
                      icon: Icons.directions_run,
                      color: Colors.lightBlue.shade800,
                    ),
                    const SizedBox(width: 16),
                    _buildInfoCard(
                      title: 'Total Distance (km)',
                      value: NumberFormat('#,###').format(totalDistanceSeven),
                      icon: Icons.arrow_circle_right_outlined,
                      color: Colors.lightBlue.shade800,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBarChart(List<StepData> data) {
    double maxSteps = 0;
    for (var i in data) {
      if (i.steps > maxSteps) maxSteps = i.steps.toDouble();
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.center,
        maxY: 12000,

        barTouchData: BarTouchData(
          enabled: true,
          touchExtraThreshold: const EdgeInsets.symmetric(horizontal: 8),
          touchTooltipData: BarTouchTooltipData(
            fitInsideVertically: true,
            getTooltipColor: (group) =>
                Colors.deepOrange.shade300.withValues(alpha: 0.5),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.round()}\nSteps', // Text content
                const TextStyle(
                  color: Colors.white, // White text
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              );
            },
          ),
        ),

        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),

          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (double value, TitleMeta meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  final date = data[index].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat.E().format(date),
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),

        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),

        barGroups: data.asMap().entries.map((entry) {
          int index = entry.key;
          StepData stepData = entry.value;

          final double visualHeight = stepData.steps > 12000
              ? 12000
              : stepData.steps.toDouble();

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: visualHeight,
                color: Colors.blue,
                width: 20,
                borderRadius: BorderRadius.circular(5),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: 12000,
                  color: Colors.lightBlue.shade100,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
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
                color: color.withValues(alpha: 1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
