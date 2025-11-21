import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class StepData {
  final DateTime date;
  final int steps;

  StepData(this.date, this.steps);
}

class ActivityDetailsScreen extends StatelessWidget {
  const ActivityDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<StepData> lastSevenDays = List.generate(7, (index) {
      DateTime date = DateTime.now().subtract(Duration(days: 6 - index));
      int steps = [500, 6200, 8900, 3400, 49000, 7500, 5000][index];
      return StepData(date, steps);
    });

    final int totalSteps = lastSevenDays.fold(
      0,
      (sum, item) => sum + item.steps,
    );
    final double totalDistance = (totalSteps * 0.0003048);

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
              height: 350,
              padding: const EdgeInsets.only(right: 16, top: 10),
              child: _buildBarChart(lastSevenDays),
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
                  value: NumberFormat('#,###').format(totalSteps),
                  icon: Icons.directions_run,
                  color: Colors.blue,
                ),
                const SizedBox(width: 16),
                _buildInfoCard(
                  title: 'Total Distance (km)',
                  value: NumberFormat('#,###').format(totalDistance),
                  icon: Icons.arrow_circle_right_outlined,
                  color: Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(List<StepData> data) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 12000,

        barTouchData: BarTouchData(
          enabled: true,
          touchExtraThreshold: const EdgeInsets.symmetric(horizontal: 8),
          touchTooltipData: BarTouchTooltipData(
            fitInsideVertically: true,
            getTooltipColor: (group) =>
                Colors.deepOrange.shade300.withValues(alpha: 25),
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
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.blueGrey,
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
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
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
