import 'package:flutter/material.dart';

class BarChartTheme extends ThemeExtension<BarChartTheme> {
  final Color barColor;
  final Color barBackgroundColor;
  final Color gridColor;
  final Color toolTipColor;
  final TextStyle labelStyle;

  const BarChartTheme({
    required this.barColor,
    required this.barBackgroundColor,
    required this.gridColor,
    required this.toolTipColor,
    required this.labelStyle,
  });

  @override
  BarChartTheme copyWith({
    Color? barColor,
    Color? barBackgroundColor,
    Color? gridColor,
    Color? toolTipColor,
    TextStyle? labelStyle,
  }) {
    return BarChartTheme(
      barColor: barColor ?? this.barColor,
      barBackgroundColor: barBackgroundColor ?? this.barBackgroundColor,
      gridColor: gridColor ?? this.gridColor,
      toolTipColor: toolTipColor ?? this.toolTipColor,
      labelStyle: labelStyle ?? this.labelStyle,
    );
  }

  @override
  BarChartTheme lerp(ThemeExtension<BarChartTheme>? other, double t) {
    if (other is! BarChartTheme) {
      return this;
    }
    return BarChartTheme(
      barColor: Color.lerp(barColor, other.barColor, t)!,
      barBackgroundColor: Color.lerp(
        barBackgroundColor,
        other.barBackgroundColor,
        t,
      )!,
      gridColor: Color.lerp(gridColor, other.gridColor, t)!,
      toolTipColor: Color.lerp(toolTipColor, other.toolTipColor, t)!,
      labelStyle: TextStyle.lerp(labelStyle, other.labelStyle, t)!,
    );
  }
}
