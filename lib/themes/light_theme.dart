import 'package:flutter/material.dart';

// Light Mode Theme
ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: Colors.white,
    primary: Color(0xFF3855A8),
    secondary: Color(0xFFF9A825),
    tertiary: Color(0xFFFFFFFF),
    inversePrimary: Color(0xFF37474F),
    error: Color(0xFFD84315),
  ),

  // Scaffold Background Color
  scaffoldBackgroundColor: Color(0xFFF5F5F5),

  // AppBar Background and Foreground Color
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF2E7D32),
    foregroundColor: Colors.white,
    elevation: 2,
  ),

  buttonTheme: ButtonThemeData(
    buttonColor: Color(0xFFF9A825),
    textTheme: ButtonTextTheme.primary,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFFF9A825),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFFFFFFFF),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF2E7D32)),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFF9A825)),
    ),
  ),
);
