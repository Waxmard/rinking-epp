import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A class for managing app-wide themes and styling for TierNerd
class AppTheme {
  // Core UI Palette - Primary color (updated to match logo background exactly)
  static const Color primaryColor = Color(0xFF5B4B89); // TierNerd logo purple
  static const Color primaryColorLight = Color(0xFF7969A3); // Lighter purple
  static const Color primaryColorDark = Color(0xFF463A6A); // Darker purple

  // Core UI Palette - Secondary/Accent color (changed from yellow to teal)
  static const Color accentColor = Color(0xFF5EC4B6); // Teal accent
  static const Color accentColorLight = Color(0xFF8FD5CC); // Lighter teal
  static const Color accentColorDark = Color(0xFF3A9C90); // Darker teal

  // Tier colors - functional colors for tier visualization only
  static const Color sTierColor = Color(0xFFEAD94C); // S - Yellow (gold)
  static const Color aTierColor = Color(0xFFF2E77F); // A - Lighter yellow
  static const Color bTierColor = Color(0xFF9DD16A); // B - Light green
  static const Color cTierColor = Color(0xFF5EC4B6); // C - Teal (same as accent)
  static const Color dTierColor = Color(0xFFA364D9); // D - Purple
  static const Color eTierColor = Color(0xFFF05F57); // E - Red
  static const Color fTierColor = Color(0xFF9E9E9E); // F - Gray

  // Grayscale palette
  static const Color textColorPrimary = Color(0xFF212121);     // Near black
  static const Color textColorSecondary = Color(0xFF757575);   // Dark gray
  static const Color dividerColor = Color(0xFFE0E0E0);         // Light gray
  static const Color backgroundColor = Color(0xFFF5F5F5);      // Almost white
  static const Color surfaceColor = Color(0xFFFFFFFF);         // Pure white
  static const Color errorColor = Color(0xFFF05F57);           // Red (using D-tier red)

  /// Default text theme with Google Fonts
  static TextTheme get textTheme {
    return TextTheme(
      displayLarge: GoogleFonts.montserrat(
        fontSize: 96,
        fontWeight: FontWeight.w300,
        letterSpacing: -1.5
      ),
      displayMedium: GoogleFonts.montserrat(
        fontSize: 60,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5
      ),
      displaySmall: GoogleFonts.montserrat(
        fontSize: 48,
        fontWeight: FontWeight.w400,
      ),
      headlineMedium: GoogleFonts.montserrat(
        fontSize: 34,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25
      ),
      headlineSmall: GoogleFonts.montserrat(
        fontSize: 24,
        fontWeight: FontWeight.w400,
      ),
      titleLarge: GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15
      ),
      titleMedium: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15
      ),
      titleSmall: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1
      ),
      bodyLarge: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5
      ),
      bodyMedium: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25
      ),
      labelLarge: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.25
      ),
      bodySmall: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4
      ),
      labelSmall: GoogleFonts.roboto(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.5
      ),
    );
  }

  /// Returns the light theme
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        error: errorColor,
        surface: surfaceColor,
        background: backgroundColor,
        onPrimary: Colors.white,
        onSecondary: Colors.black, // Black text on yellow for better contrast
        onSurface: textColorPrimary,
        onBackground: textColorPrimary,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 4.0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 1.0,  // Subtle elevation
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),  // Less rounded for minimalist look
        ),
        margin: const EdgeInsets.all(8.0),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.black, // Black on yellow for contrast
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1.0,
        space: 1.0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: primaryColor, width: 2.0),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: textColorSecondary),
        hintStyle: textTheme.bodyMedium?.copyWith(color: textColorSecondary.withOpacity(0.7)),
      ),
    );
  }

  /// Returns the dark theme - adapted to TierNerd colors
  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        error: errorColor,
        surface: Color(0xFF473A71),      // Dark purple surface
        background: Color(0xFF382D5C),   // Darker purple background
        onPrimary: Colors.white,
        onSecondary: Colors.black,       // Black on yellow for contrast
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),
      scaffoldBackgroundColor: Color(0xFF382D5C), // Dark purple background
      textTheme: textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0.0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColorLight,
          foregroundColor: Colors.white,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Color(0xFF473A71), // Dark purple card
        elevation: 1.0,  // Subtle elevation
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),  // Less rounded for minimalist look
        ),
        margin: const EdgeInsets.all(8.0),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.black, // Black on yellow for contrast
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withOpacity(0.2),
        thickness: 1.0,
        space: 1.0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: accentColor, width: 2.0),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.7)),
        hintStyle: textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.5)),
      ),
    );
  }

  /// Helper method to get tier color by tier letter
  static Color getTierColor(String tier) {
    switch (tier.toUpperCase()) {
      case 'S':
        return sTierColor;
      case 'A':
        return aTierColor;
      case 'B':
        return bTierColor;
      case 'C':
        return cTierColor;
      case 'D':
        return dTierColor;
      case 'E':
        return eTierColor;
      case 'F':
        return fTierColor;
      default:
        return Colors.grey;
    }
  }
}
