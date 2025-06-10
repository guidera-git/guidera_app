// app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Dark theme colors
  static const Color myBlack = Color(0xFF222222);
  static const Color lightBlue = Color(0xFF2D8CFF);
  static const Color darkGray = Color(0xFFFAF2F2);
  static const Color lightGray = Color(0xFFE7E7E7);
  static const Color darkBlack = Color(0xFF000000);
  static const Color lightBlack = Color(0xFF565756);
  static const Color myGray = Color(0xFFC7C6C6);
  static const Color myWhite = Color(0xFFF3F3F3);
  static const Color darkBlue = Color(0xFF196FB6);

  // Light theme specific colors
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF2D8CFF);
  static const Color lightSecondary = Color(0xFF196FB6);
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF666666);
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color lightCardShadow = Color(0x0A000000);

  /// Returns the appropriate background color based on theme
  static Color backgroundColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? myBlack : lightBackground;
  }

  /// Returns the appropriate surface color for cards/containers
  static Color surfaceColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? lightBlack : lightSurface;
  }

  /// Returns the appropriate primary text color
  static Color textPrimary(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? myWhite : lightTextPrimary;
  }

  /// Returns the appropriate secondary text color
  static Color textSecondary(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? myGray : lightTextSecondary;
  }

  /// Returns the appropriate primary color
  static Color primary(BuildContext context) {
    return lightBlue; // Same for both themes
  }

  /// Returns the appropriate secondary color
  static Color secondary(BuildContext context) {
    return darkBlue; // Same for both themes
  }

  /// Returns the appropriate drawer background color
  static Color drawerBackground(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? myBlack : lightSurface;
  }

  /// Returns the appropriate border color
  static Color borderColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? myGray : lightBorder;
  }

  /// Returns the appropriate shadow color
  static Color shadowColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? myBlack.withOpacity(0.3) : lightCardShadow;
  }

  /// Returns contrasting color for text on given background
  static Color getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? lightTextPrimary : myWhite;
  }

  /// Legacy methods for backward compatibility
  static Color navBarColor(BuildContext context) => surfaceColor(context);
  static Color primaryColor(BuildContext context) => backgroundColor(context);
}