import 'package:flutter/material.dart';

// Dark Mode Theme for Land and House Registration App
ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    background: Color(0xFF121212), // Deep Charcoal for background
    primary: Color(0xFF4CAF50), // Vibrant Green for primary elements
    secondary: Color(0xFFFFC107), // Amber Yellow for CTA buttons
    tertiary: Color(0xFF1E1E1E), // Darker Card/Container Background
    inversePrimary: Color(0xFFE0E0E0), // Light Gray for text/icons
    error: Color(0xFFFF7043), // Coral Red for error states
  ),
  scaffoldBackgroundColor:
      Color(0xFF121212), // Consistent dark scaffold background
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF1B5E20), // Dark Green AppBar
    foregroundColor: Colors.white,
    elevation: 2,
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Color(0xFFFFC107), // Yellow buttons for visibility
    textTheme: ButtonTextTheme.primary,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFFFFC107), // Amber for CTA buttons
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF1E1E1E), // Dark fill for inputs
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF4CAF50)), // Green border
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFFFC107)), // Amber focus border
    ),
  ),
  cardColor: Color(0xFF1E1E1E), // Dark cards for consistency
);
