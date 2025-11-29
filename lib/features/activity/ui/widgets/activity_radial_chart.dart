import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

//widget to make radial chart
class ActivityRadialChart extends StatelessWidget {
  final int steps;
  final double distance;
  final double calories;

  const ActivityRadialChart({
    super.key,
    required this.steps,
    required this.distance,
    required this.calories,
  });

  @override
  Widget build(BuildContext context) {
    const int stepMax = 10000;
    const double distanceMax = 5;
    const double caloriesMax = 500;

    //define chart data
    final List<ChartData> chartData = [
      ChartData(
        'Steps',
        steps.toDouble(),
        stepMax.toDouble(),
        Colors.orangeAccent,
        Icons.directions_walk,
      ),
      ChartData(
        'Distance',
        distance,
        distanceMax,
        Colors.greenAccent,
        Icons.map,
      ),
      ChartData(
        'Calories',
        calories,
        caloriesMax,
        Colors.blueAccent,
        Icons.local_fire_department,
      ),
    ];

    //actually making the chart
    return SfCircularChart(
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        iconHeight: 10,
        iconWidth: 10,
        overflowMode: LegendItemOverflowMode.wrap,
      ),
      series: <CircularSeries>[
        RadialBarSeries<ChartData, String>(
          dataSource: chartData,
          xValueMapper: (ChartData data, _) => data.category,
          yValueMapper: (ChartData data, _) => data.value,
          pointColorMapper: (ChartData data, _) => data.color,
          maximumValue: 100,
          cornerStyle: CornerStyle.bothFlat,
          gap: '10%',
          radius: '90%',
          innerRadius: '50%',
          trackOpacity: 0.3,
          useSeriesColor: true,
          legendIconType: LegendIconType.circle,
        ),
      ],
      annotations: <CircularChartAnnotation>[
        CircularChartAnnotation(
          widget: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                steps.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Steps',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

//data model for the chart
class ChartData {
  final String category;
  final double value;
  final double max;
  final Color color;
  final IconData icon;

  ChartData(this.category, double rawValue, this.max, this.color, this.icon)
    : value = ((rawValue / max) * 100).clamp(0, 100);
}
