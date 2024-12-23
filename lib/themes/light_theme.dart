import 'package:flutter/material.dart';

// Light Mode Theme for Land and House Registration App
ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    background: Colors.white, // Tertiary - Soft White for background
    primary: Color(0xFF3855A8), // Primary - Forest Green
    secondary: Color(0xFFF9A825), // Secondary - Golden Yellow
    tertiary: Color(0xFFFFFFFF), // Pure White for clean surfaces
    inversePrimary: Color(0xFF37474F), // Text and Icon Color - Dark Slate Gray
    error: Color(0xFFD84315), // Accent/Error - Deep Orange
  ),
  // AppBar uses primary color
  // AppBar text/icons in white
  // CTA buttons in secondary (golden yellow)

  scaffoldBackgroundColor:
      Color(0xFFF5F5F5), // Consistent background for scaffold
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF2E7D32), // AppBar uses primary color
    foregroundColor: Colors.white, // AppBar text/icons in white
    elevation: 2,
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Color(0xFFF9A825), // CTA buttons in secondary (golden yellow)
    textTheme: ButtonTextTheme.primary,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFFF9A825), // Elevated button color
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFFFFFFFF), // Input fields with white background
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF2E7D32)), // Green border
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFF9A825)), // Yellow on focus
    ),
  ),
);
