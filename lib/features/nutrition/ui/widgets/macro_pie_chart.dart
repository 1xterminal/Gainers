import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/animated_counter.dart';

class MacroPieChart extends StatefulWidget {
  final int protein;
  final int carbs;
  final int fat;
  final int totalCalories;
  final VoidCallback onTap;

  const MacroPieChart({
    super.key,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.totalCalories,
    required this.onTap,
  });

  @override
  State<MacroPieChart> createState() => _MacroPieChartState();
}

class _MacroPieChartState extends State<MacroPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalGrams = widget.protein + widget.carbs + widget.fat;

    // Avoid division by zero
    final pVal = totalGrams > 0 ? (widget.protein / totalGrams) * 100 : 0.0;
    final cVal = totalGrams > 0 ? (widget.carbs / totalGrams) * 100 : 0.0;
    final fVal = totalGrams > 0 ? (widget.fat / totalGrams) * 100 : 0.0;

    // If no data, show a grey placeholder
    final isEmpty = totalGrams == 0;

    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        height: 200,
        child: Stack(
          children: [
            PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 60,
                sections: isEmpty
                    ? [
                        PieChartSectionData(
                          color: Colors.grey[200],
                          value: 100,
                          title: '',
                          radius: 20,
                        ),
                      ]
                    : [
                        _buildSection(0, pVal, Colors.redAccent, 'Protein'),
                        _buildSection(1, cVal, Colors.blueAccent, 'Carbs'),
                        _buildSection(2, fVal, Colors.orangeAccent, 'Fat'),
                      ],
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: widget.totalCalories),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutExpo,
                    builder: (context, value, child) {
                      return Text(
                        '$value',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      );
                    },
                  AnimatedCounter(
                    value: widget.totalCalories,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  Text(
                    'Kcal',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PieChartSectionData _buildSection(
    int index,
    double value,
    Color color,
    String title,
  ) {
    final isTouched = index == touchedIndex;
    final fontSize = isTouched ? 16.0 : 12.0;
    final radius = isTouched ? 30.0 : 25.0;

    return PieChartSectionData(
      color: color,
      value: value,
      title: '${value.toStringAsFixed(0)}%',
      radius: radius,
      titleStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}
