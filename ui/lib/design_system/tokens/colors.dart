import 'package:flutter/material.dart';

/// Comprehensive color system with semantic naming
class AppColors {
  // Brand colors
  static const MaterialColor primary = MaterialColor(
    0xFF5B4B89,
    <int, Color>{
      50: Color(0xFFECE9F1),
      100: Color(0xFFD0C8DD),
      200: Color(0xFFB1A4C6),
      300: Color(0xFF927FAF),
      400: Color(0xFF7A639D),
      500: Color(0xFF5B4B89), // Base
      600: Color(0xFF534481),
      700: Color(0xFF493B76),
      800: Color(0xFF40326C),
      900: Color(0xFF2F2359),
    },
  );

  static const MaterialColor accent = MaterialColor(
    0xFF5EC4B6,
    <int, Color>{
      50: Color(0xFFEBF7F5),
      100: Color(0xFFCEEBE6),
      200: Color(0xFFADDED5),
      300: Color(0xFF8CD1C4),
      400: Color(0xFF74C7B8),
      500: Color(0xFF5EC4B6), // Base
      600: Color(0xFF56BEAF),
      700: Color(0xFF4BB5A5),
      800: Color(0xFF41AD9C),
      900: Color(0xFF309F8B),
    },
  );

  // Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFF05F57);
  static const Color info = Color(0xFF2196F3);

  // Tier colors (functional)
  static const Color tierS = Color(0xFFEAD94C);
  static const Color tierA = Color(0xFFF2E77F);
  static const Color tierB = Color(0xFF9DD16A);
  static const Color tierC = Color(0xFF5EC4B6);
  static const Color tierD = Color(0xFFA364D9);
  static const Color tierF = Color(0xFFF05F57);

  // Neutral colors
  static const MaterialColor neutral = MaterialColor(
    0xFF757575,
    <int, Color>{
      50: Color(0xFFFAFAFA),
      100: Color(0xFFF5F5F5),
      200: Color(0xFFEEEEEE),
      300: Color(0xFFE0E0E0),
      400: Color(0xFFBDBDBD),
      500: Color(0xFF9E9E9E),
      600: Color(0xFF757575), // Base
      700: Color(0xFF616161),
      800: Color(0xFF424242),
      900: Color(0xFF212121),
    },
  );

  // Surface colors for light theme
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color cardLight = Color(0xFFFFFFFF);

  // Surface colors for dark theme
  static const Color surfaceDark = Color(0xFF473A71);
  static const Color backgroundDark = Color(0xFF382D5C);
  static const Color cardDark = Color(0xFF473A71);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFF000000);

  // Dark theme text colors
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textDisabledDark = Color(0xFF616161);

  // Special colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0x33FFFFFF);
  static const Color overlay = Color(0x80000000);
  static const Color scrim = Color(0x52000000);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7969A3),
      Color(0xFF5B4B89),
      Color(0xFF463A6A),
    ],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF8FD5CC),
      Color(0xFF5EC4B6),
      Color(0xFF3A9C90),
    ],
  );

  // Shadow colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x29000000);
  static const Color shadowDark = Color(0x3D000000);

  // Helper methods
  static Color getTierColor(String tier) {
    switch (tier.toUpperCase()) {
      case 'S': return tierS;
      case 'A': return tierA;
      case 'B': return tierB;
      case 'C': return tierC;
      case 'D': return tierD;
      case 'F': return tierF;
      default: return neutral;
    }
  }

  static Color getContrastText(Color background) {
    return ThemeData.estimateBrightnessForColor(background) == Brightness.light
        ? textPrimary
        : textOnPrimary;
  }
}