import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:gainers/core/theme/app_theme.dart';
import 'package:gainers/features/activity/data/models/step_data.dart';

//widget for the main 7 day bar chart
class ActivityBarChart extends StatelessWidget {
  final List<StepData> data;
  final int selectedIndex;
  final Function(int) onBarSelected;

  const ActivityBarChart({
    super.key,
    required this.data,
    required this.selectedIndex,
    required this.onBarSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<BarChartTheme>()!;

    return BarChart(
      //animation for smooth transitions
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,

      BarChartData(
        alignment: BarChartAlignment.center,
        maxY: 10000, //max value (recommended step count for adults)
        //handle touch events
        barTouchData: BarTouchData(
          enabled: true,
          handleBuiltInTouches: false,
          touchCallback: (FlTouchEvent event, barTouchResponse) {
            if (event is! FlTapUpEvent) {
              return;
            }

            if (barTouchResponse == null || barTouchResponse.spot == null) {
              onBarSelected(-1);
              return;
            }

            onBarSelected(barTouchResponse.spot!.touchedBarGroupIndex);
          },
        ),

        //axis titles, the bottom titles are the days
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
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat.E().format(data[index].date),
                      style: theme.labelStyle,
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

          //cap visual height at 10k
          final double visualHeight = stepData.steps > 10000
              ? 10000
              : stepData.steps.toDouble();

          final isSelected = index == selectedIndex;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: visualHeight,
                gradient: LinearGradient(
                  colors: isSelected
                      ? [theme.barColor, theme.toolTipColor]
                      : [theme.barColor, theme.barColor],
                  stops: const [0.4, 1.0],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 30,
                borderRadius: BorderRadius.circular(20),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: 10000,
                  color: theme.barBackgroundColor,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
