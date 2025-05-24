import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography system with consistent text styles
class AppTypography {
  // Font families
  static String get headingFont => GoogleFonts.montserrat().fontFamily!;
  static String get bodyFont => GoogleFonts.roboto().fontFamily!;

  // Font sizes
  static const double sizeXxs = 10.0;
  static const double sizeXs = 12.0;
  static const double sizeSm = 14.0;
  static const double sizeMd = 16.0;
  static const double sizeLg = 20.0;
  static const double sizeXl = 24.0;
  static const double sizeXxl = 32.0;
  static const double sizeXxxl = 48.0;
  static const double sizeDisplay = 64.0;

  // Line heights as multipliers
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.75;

  // Font weights
  static const FontWeight weightLight = FontWeight.w300;
  static const FontWeight weightRegular = FontWeight.w400;
  static const FontWeight weightMedium = FontWeight.w500;
  static const FontWeight weightSemiBold = FontWeight.w600;
  static const FontWeight weightBold = FontWeight.w700;

  // Letter spacing
  static const double letterSpacingTight = -0.5;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.5;
  static const double letterSpacingExtraWide = 1.0;

  // Pre-defined text styles
  static TextStyle displayLarge = GoogleFonts.montserrat(
    fontSize: sizeDisplay,
    fontWeight: weightLight,
    letterSpacing: letterSpacingTight,
    height: lineHeightTight,
  );

  static TextStyle displayMedium = GoogleFonts.montserrat(
    fontSize: sizeXxxl,
    fontWeight: weightLight,
    letterSpacing: letterSpacingTight,
    height: lineHeightTight,
  );

  static TextStyle displaySmall = GoogleFonts.montserrat(
    fontSize: sizeXxl,
    fontWeight: weightRegular,
    height: lineHeightTight,
  );

  static TextStyle headlineLarge = GoogleFonts.montserrat(
    fontSize: sizeXxl,
    fontWeight: weightSemiBold,
    height: lineHeightTight,
  );

  static TextStyle headlineMedium = GoogleFonts.montserrat(
    fontSize: sizeXl,
    fontWeight: weightMedium,
    height: lineHeightNormal,
  );

  static TextStyle headlineSmall = GoogleFonts.montserrat(
    fontSize: sizeLg,
    fontWeight: weightMedium,
    height: lineHeightNormal,
  );

  static TextStyle titleLarge = GoogleFonts.montserrat(
    fontSize: sizeLg,
    fontWeight: weightSemiBold,
    height: lineHeightNormal,
  );

  static TextStyle titleMedium = GoogleFonts.roboto(
    fontSize: sizeMd,
    fontWeight: weightMedium,
    height: lineHeightNormal,
  );

  static TextStyle titleSmall = GoogleFonts.roboto(
    fontSize: sizeSm,
    fontWeight: weightMedium,
    letterSpacing: letterSpacingWide,
    height: lineHeightNormal,
  );

  static TextStyle bodyLarge = GoogleFonts.roboto(
    fontSize: sizeMd,
    fontWeight: weightRegular,
    height: lineHeightRelaxed,
  );

  static TextStyle bodyMedium = GoogleFonts.roboto(
    fontSize: sizeSm,
    fontWeight: weightRegular,
    height: lineHeightRelaxed,
  );

  static TextStyle bodySmall = GoogleFonts.roboto(
    fontSize: sizeXs,
    fontWeight: weightRegular,
    height: lineHeightRelaxed,
  );

  static TextStyle labelLarge = GoogleFonts.roboto(
    fontSize: sizeSm,
    fontWeight: weightMedium,
    letterSpacing: letterSpacingExtraWide,
    height: lineHeightNormal,
  );

  static TextStyle labelMedium = GoogleFonts.roboto(
    fontSize: sizeXs,
    fontWeight: weightMedium,
    letterSpacing: letterSpacingWide,
    height: lineHeightNormal,
  );

  static TextStyle labelSmall = GoogleFonts.roboto(
    fontSize: sizeXxs,
    fontWeight: weightMedium,
    letterSpacing: letterSpacingExtraWide,
    height: lineHeightNormal,
  );

  // Specialized styles
  static TextStyle button = GoogleFonts.roboto(
    fontSize: sizeSm,
    fontWeight: weightMedium,
    letterSpacing: letterSpacingWide,
    height: 1.0, // Tighter line height for buttons
  );

  static TextStyle caption = GoogleFonts.roboto(
    fontSize: sizeXs,
    fontWeight: weightRegular,
    height: lineHeightNormal,
  );

  static TextStyle overline = GoogleFonts.roboto(
    fontSize: sizeXxs,
    fontWeight: weightMedium,
    letterSpacing: letterSpacingExtraWide,
    height: lineHeightNormal,
  );

  // Helper method for responsive font sizes
  static double responsiveFontSize(BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1000 && desktop != null) return desktop;
    if (width >= 600 && tablet != null) return tablet;
    return mobile;
  }
}