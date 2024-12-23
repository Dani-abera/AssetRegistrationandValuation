import 'package:flutter/material.dart';
import 'package:land_house_verify/themes/dark_theme.dart';
import 'package:land_house_verify/themes/light_theme.dart';

// ThemeProvider class to manage theme state, extending ChangeNotifier for state management
class ThemeProvider with ChangeNotifier {
  // Private variable to hold the current theme data, initialized to light mode
  ThemeData _themeData = lightMode;

  // Getter to retrieve the current theme data
  ThemeData get themeData => _themeData;

  // Getter to check if the current theme is dark mode
  bool get isDarkMode => _themeData == darkMode;

  // Setter to update the theme data and notify listeners about the change
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners(); // Notifies all the widgets listening to this provider to rebuild
  }

  // Method to toggle between light and dark themes
  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode; // Switch to dark mode
    } else {
      themeData = lightMode; // Switch to light mode
    }
  }
}
