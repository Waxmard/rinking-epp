import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A class for managing app-wide themes and styling
class AppTheme {
  // Primary color and its variations
  static const Color primaryColor = Color(0xFF6200EE);
  static const Color primaryColorLight = Color(0xFF9E67E1);
  static const Color primaryColorDark = Color(0xFF3700B3);
  
  // Accent/Secondary color and its variations  
  static const Color accentColor = Color(0xFF03DAC5);
  static const Color accentColorLight = Color(0xFF66FFF0);
  static const Color accentColorDark = Color(0xFF018786);
  
  // Neutral colors
  static const Color textColorPrimary = Color(0xFF212121);
  static const Color textColorSecondary = Color(0xFF757575);
  static const Color dividerColor = Color(0xFFBDBDBD);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFB00020);

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
      cardTheme: CardTheme(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: const EdgeInsets.all(8.0),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.black,
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

  /// Returns the dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: primaryColorLight,
      colorScheme: ColorScheme.dark(
        primary: primaryColorLight,
        secondary: accentColorLight,
        error: errorColor,
        surface: Colors.grey[900]!,
        background: Colors.grey[850]!,
      ),
      scaffoldBackgroundColor: Colors.grey[900],
      textTheme: textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
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
      cardTheme: CardTheme(
        color: Colors.grey[800],
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: const EdgeInsets.all(8.0),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColorLight,
        foregroundColor: Colors.black,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey[700]!,
        thickness: 1.0,
        space: 1.0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: primaryColorLight, width: 2.0),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
        hintStyle: textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
      ),
    );
  }
}