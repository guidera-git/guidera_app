// app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // 1) Light theme colors
  static const Color myBlack = Color(0xFF222222);
  static const Color lightBlue = Color(0xFF2D8CFF);
  static const Color darkGray = Color (0xFFFAF2F2);
  // Add as many light-theme colors as you need...

  // 2) Dark theme colors
  static const Color myGray = Color(0xFFC7C6C6);
  static const Color myWhite = Color(0xFFF3F3F3);
  static const Color darkBlue = Color(0xFF196FB6);
  // Add as many dark-theme colors as you need...

  /// Returns the appropriate nav bar color based on the current theme's brightness.
  static Color navBarColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? myBlack : myWhite;
  }

  /// Example: returns the appropriate primary color based on theme.
  static Color primaryColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? myBlack :myWhite ;
  }

// You can add more helper methods for other color pairs, e.g.:
// static Color backgroundColor(BuildContext context) { ... }
// static Color accentColor(BuildContext context) { ... }
}
