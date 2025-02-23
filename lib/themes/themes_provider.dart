import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:land_house_verify/themes/dark_theme.dart';
import 'package:land_house_verify/themes/light_theme.dart';

// Riverpod-compatible ThemeProvider using Notifier
class ThemeProvider extends Notifier<ThemeData> {
  // Initialize the theme to light mode
  @override
  ThemeData build() => lightMode;

  // Getter to check if the current theme is dark mode
  bool get isDarkMode => state == darkMode;

  // Method to toggle between light and dark themes
  void toggleTheme() {
    state = (state == lightMode) ? darkMode : lightMode;
  }
}

// Define a global Riverpod provider for ThemeProvider
final themeProvider = NotifierProvider<ThemeProvider, ThemeData>(() {
  return ThemeProvider();
});
