import 'package:flutter/material.dart';
import 'bar_chart_theme.dart';

export 'bar_chart_theme.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.grey[50],
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.blue,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.black12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.black12),
      ),
    ),

    extensions: <ThemeExtension<dynamic>>[
      BarChartTheme(
        barColor: Colors.blue,
        barBackgroundColor: Colors.lightBlue.shade100,
        gridColor: Colors.white,
        toolTipColor: Colors.orange.shade400,
        labelStyle: TextStyle(color: Colors.lightBlue.shade800, fontSize: 12),
      ),
    ],
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blueAccent,
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardTheme: CardThemeData(
      elevation: 1,
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.blueAccent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey),
      ),
    ),

    extensions: <ThemeExtension<dynamic>>[
      BarChartTheme(
        barColor: Colors.greenAccent.shade200,
        barBackgroundColor: Colors.deepPurple,
        gridColor: Colors.grey.shade900,
        toolTipColor: Colors.pink.shade400,
        labelStyle: TextStyle(color: Colors.greenAccent, fontSize: 12),
      ),
    ],
  );
}
