import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color brandTeal = Color(0xFF008B8B);
  static const Color brandBlack = Color(0xFF1A1A1A);
  static const Color backgroundWhite = Colors.white;
  static const Color surfaceWhite = Color(0xFFFAFAFA);
  static const Color inactiveGrey = Color(0xFF9E9E9E);

  // Card Styling
  static final CardTheme cardTheme = CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    color: backgroundWhite,
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  );

  // Input Decoration
  static final InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: brandTeal, width: 2),
    ),
    floatingLabelStyle: const TextStyle(color: brandTeal),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  // Bottom Navigation Bar Theme
  static final BottomNavigationBarThemeData bottomNavigationBarTheme = BottomNavigationBarThemeData(
    backgroundColor: backgroundWhite,
    selectedItemColor: brandTeal,
    unselectedItemColor: inactiveGrey,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  );

  // App Bar Theme
  static final AppBarTheme appBarTheme = AppBarTheme(
    backgroundColor: backgroundWhite,
    elevation: 0,
    centerTitle: true,
    iconTheme: const IconThemeData(color: brandBlack),
    titleTextStyle: const TextStyle(
      color: brandBlack,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  );

  // Text Theme
  static final TextTheme textTheme = TextTheme(
    headlineLarge: const TextStyle(
      color: brandBlack,
      fontSize: 28,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: const TextStyle(
      color: brandBlack,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: const TextStyle(
      color: brandBlack,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: const TextStyle(
      color: brandBlack,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: TextStyle(
      color: brandBlack.withOpacity(0.87),
      fontSize: 16,
    ),
    bodyMedium: TextStyle(
      color: brandBlack.withOpacity(0.87),
      fontSize: 14,
    ),
  );

  // Elevated Button Theme
  static final ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: brandTeal,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
    ),
  );

  // Main Theme Data
  static ThemeData themeData = ThemeData(
    primaryColor: brandTeal,
    scaffoldBackgroundColor: backgroundWhite,
    cardTheme: cardTheme,
    inputDecorationTheme: inputDecorationTheme,
    bottomNavigationBarTheme: bottomNavigationBarTheme,
    appBarTheme: appBarTheme,
    textTheme: textTheme,
    elevatedButtonTheme: elevatedButtonTheme,
    colorScheme: ColorScheme.light(
      primary: brandTeal,
      secondary: brandTeal,
      surface: surfaceWhite,
      background: backgroundWhite,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: brandBlack,
      onBackground: brandBlack,
    ),
  );
} 