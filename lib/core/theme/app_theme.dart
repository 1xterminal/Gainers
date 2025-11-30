import 'package:flutter/material.dart';
import 'bar_chart_theme.dart';

export 'bar_chart_theme.dart';

class AppTheme {
  // --- Colors ---
  // Light Mode
  static const Color _lightPrimary = Color(0xFF8D5524); // Brown
  static const Color _lightSecondary = Color(0xFFFFB088); // Peach
  static const Color _lightBackground = Color(0xFFFFF0E6); // Cream
  static const Color _lightSurface = Colors.white;
  static const Color _lightError = Color(0xFFD32F2F);

  // Dark Mode
  static const Color _darkPrimary = Color(0xFFFFB088); // Peach
  static const Color _darkSecondary = Color(0xFF8D5524); // Brown
  static const Color _darkBackground = Color(0xFF2D1E17); // Dark Brown
  static const Color _darkSurface = Color(0xFF3E2D25); // Slightly lighter brown
  static const Color _darkError = Color(0xFFEF5350);

  // --- Typography ---
  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontFamily: 'Lexend',
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontFamily: 'Lexend',
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontFamily: 'Lexend',
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontFamily: 'Lexend',
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontFamily: 'Lexend',
        fontWeight: FontWeight.w600,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontFamily: 'Lexend',
        fontWeight: FontWeight.w600,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontFamily: 'Lexend',
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontFamily: 'Lexend',
        fontWeight: FontWeight.w400,
        fontSize: 16,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontFamily: 'Lexend',
        fontWeight: FontWeight.w400,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontFamily: 'Lexend',
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
      error: _lightError,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black87,
      onError: Colors.white,
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
      backgroundColor: _lightBackground,
      foregroundColor: Colors.black87,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.black87),
      titleTextStyle: TextStyle(
        fontFamily: 'Lexend',
        color: Colors.black87,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // Cards
    cardTheme: CardThemeData(
      elevation: 0,
      color: _lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    ),

    // Inputs (Default fallback, though we use CustomTextField)
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
    ),

    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _lightPrimary,
      foregroundColor: Colors.white,
      elevation: 4,
    ),

    // Extensions
    extensions: <ThemeExtension<dynamic>>[
      BarChartTheme(
        barColor: _lightPrimary,
        barBackgroundColor: _lightPrimary.withValues(alpha: 0.1),
        gridColor: Colors.black12,
        toolTipColor: _lightSecondary,
        labelStyle: const TextStyle(
          fontFamily: 'Lexend',
          color: _lightPrimary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        greenBars: const Color(0xFF4CAF50),
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
      error: _darkError,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onError: Colors.white,
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
      titleTextStyle: TextStyle(
        fontFamily: 'Lexend',
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // Cards
    cardTheme: CardThemeData(
      elevation: 0,
      color: _darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
    ),

    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _darkPrimary,
      foregroundColor: Colors.black,
      elevation: 4,
    ),

    extensions: <ThemeExtension<dynamic>>[
      BarChartTheme(
        barColor: _darkPrimary,
        barBackgroundColor: _darkPrimary.withValues(alpha: 0.1),
        gridColor: Colors.white12,
        toolTipColor: _darkSecondary,
        labelStyle: const TextStyle(
          fontFamily: 'Lexend',
          color: _darkPrimary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        greenBars: const Color(0xFF66BB6A),
      ),
    ],
  );
}
