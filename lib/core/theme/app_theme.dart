import 'package:flutter/material.dart';
import 'bar_chart_theme.dart';

export 'bar_chart_theme.dart';

class AppTheme {
  // --- Premium Color Palette ---
  static const Color _lightPrimary = Color(0xFF1A237E); // Midnight Blue
  static const Color _lightSecondary = Color(0xFFFF6D00); // Vibrant Orange
  static const Color _lightBackground = Color(0xFFF5F7FA); // Soft Grey-Blue
  static const Color _lightSurface = Colors.white;

  static const Color _darkPrimary = Color(0xFF5C6BC0); // Lighter Indigo
  static const Color _darkSecondary = Color(0xFFFF9E80); // Soft Orange
  static const Color _darkBackground = Color(0xFF121212); // Deep Black
  static const Color _darkSurface = Color(0xFF1E1E1E); // Dark Grey

  // --- Typography ---
  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: base.bodyLarge?.copyWith(
        fontWeight: FontWeight.w400,
        fontSize: 16,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  // --- Light Theme ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: _lightPrimary,
    scaffoldBackgroundColor: _lightBackground,
    colorScheme: const ColorScheme.light(
      primary: _lightPrimary,
      secondary: _lightSecondary,
      surface: _lightSurface,
      background: _lightBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
    ),

    // Typography
    textTheme: _buildTextTheme(
      Typography.englishLike2018.apply(
        fontSizeFactor: 1.0,
        bodyColor: Colors.black87,
        displayColor: Colors.black87,
      ),
    ),

    // AppBar
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: _lightBackground, // Blend with background
      foregroundColor: _lightPrimary,
      centerTitle: true,
      iconTheme: IconThemeData(color: _lightPrimary),
    ),

    // Cards
    cardTheme: CardThemeData(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      color: _lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Softer corners
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    ),

    // Inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _lightPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      labelStyle: const TextStyle(color: Colors.grey),
      floatingLabelStyle: const TextStyle(color: _lightPrimary),
    ),

    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: _lightPrimary.withOpacity(0.4),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _lightPrimary,
        side: const BorderSide(color: _lightPrimary, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _lightPrimary,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),

    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _lightSecondary,
      foregroundColor: Colors.white,
      elevation: 6,
    ),

    // Extensions
    extensions: <ThemeExtension<dynamic>>[
      BarChartTheme(
        barColor: _lightPrimary,
        barBackgroundColor: _lightPrimary.withOpacity(0.1),
        gridColor: Colors.grey.withOpacity(0.2),
        toolTipColor: _lightSecondary,
        labelStyle: const TextStyle(
          color: _lightPrimary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );

  // --- Dark Theme ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: _darkPrimary,
    scaffoldBackgroundColor: _darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: _darkPrimary,
      secondary: _darkSecondary,
      surface: _darkSurface,
      background: _darkBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.white,
    ),

    // Typography
    textTheme: _buildTextTheme(
      Typography.englishLike2018.apply(
        fontSizeFactor: 1.0,
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
    ),

    // AppBar
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: _darkBackground,
      foregroundColor: Colors.white,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
    ),

    // Cards
    cardTheme: CardThemeData(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.3),
      color: _darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    ),

    // Inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _darkPrimary, width: 2),
      ),
      labelStyle: const TextStyle(color: Colors.grey),
      floatingLabelStyle: const TextStyle(color: _darkPrimary),
    ),

    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: _darkPrimary.withOpacity(0.4),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white70, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _darkSecondary,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),

    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _darkSecondary,
      foregroundColor: Colors.black,
      elevation: 6,
    ),

    // Extensions
    extensions: <ThemeExtension<dynamic>>[
      BarChartTheme(
        barColor: _darkPrimary,
        barBackgroundColor: _darkPrimary.withOpacity(0.1),
        gridColor: Colors.white10,
        toolTipColor: _darkSecondary,
        labelStyle: const TextStyle(
          color: _darkPrimary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}
