import 'package:flutter/material.dart';

// Dark Mode Theme
ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    surface: Color(0xFF121212),
    primary: Color(0xFF4CAF50),
    secondary: Color(0xFFFFC107),
    tertiary: Color(0xFF1E1E1E),
    inversePrimary: Color(0xFFE0E0E0),
    error: Color(0xFFFF7043),
  ),
  scaffoldBackgroundColor: Color(0xFF121212),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF1B5E20),
    foregroundColor: Colors.white,
    elevation: 2,
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Color(0xFFFFC107),
    textTheme: ButtonTextTheme.primary,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFFFFC107),
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF1E1E1E),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF4CAF50)),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFFFC107)), // Amber focus border
    ),
  ),
  cardColor: Color(0xFF1E1E1E),
);
