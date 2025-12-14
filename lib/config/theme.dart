import 'package:flutter/material.dart';

/// Application theme configuration
class AppTheme {
  AppTheme._();

  // Colors
  static const Color primaryColor = Color(0xFF1A365D);
  static const Color accentColor = Color(0xFFC9A227);
  static const Color backgroundColor = Color(0xFFFAF8F5);
  static const Color textColor = Color(0xFF1A1A1A);
  static const Color secondaryTextColor = Color(0xFF4A5568);
  static const Color successColor = Color(0xFF38A169);
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color cardColor = Colors.white;
  static const Color dividerColor = Color(0xFFE2E8F0);

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: cardColor,
        error: errorColor,
      ),
      fontFamily: 'David',
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'David',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: secondaryTextColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontFamily: 'David',
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'David',
          fontSize: 14,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        headlineSmall: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          color: textColor,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: textColor,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          color: secondaryTextColor,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: primaryColor,
      ),
    );
  }
}
