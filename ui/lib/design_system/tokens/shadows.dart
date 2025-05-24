import 'package:flutter/material.dart';
import 'colors.dart';

/// Elevation and shadow system
class AppShadows {
  // Elevation levels
  static const double elevationNone = 0.0;
  static const double elevationXs = 1.0;
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationXl = 16.0;

  // Box shadows for light theme
  static const BoxShadow none = BoxShadow(
    color: Colors.transparent,
  );

  static const BoxShadow xs = BoxShadow(
    color: AppColors.shadowLight,
    offset: Offset(0, 1),
    blurRadius: 2,
    spreadRadius: 0,
  );

  static const BoxShadow sm = BoxShadow(
    color: AppColors.shadowLight,
    offset: Offset(0, 2),
    blurRadius: 4,
    spreadRadius: 0,
  );

  static const BoxShadow md = BoxShadow(
    color: AppColors.shadowMedium,
    offset: Offset(0, 4),
    blurRadius: 8,
    spreadRadius: 0,
  );

  static const BoxShadow lg = BoxShadow(
    color: AppColors.shadowMedium,
    offset: Offset(0, 8),
    blurRadius: 16,
    spreadRadius: 0,
  );

  static const BoxShadow xl = BoxShadow(
    color: AppColors.shadowDark,
    offset: Offset(0, 16),
    blurRadius: 32,
    spreadRadius: 0,
  );

  // Inset shadows
  static const BoxShadow insetSm = BoxShadow(
    color: AppColors.shadowLight,
    offset: Offset(0, -1),
    blurRadius: 2,
    spreadRadius: 0,
  );

  static const BoxShadow insetMd = BoxShadow(
    color: AppColors.shadowMedium,
    offset: Offset(0, -2),
    blurRadius: 4,
    spreadRadius: 0,
  );

  // Shadow lists for components
  static const List<BoxShadow> cardShadow = [sm];
  static const List<BoxShadow> buttonShadow = [xs];
  static const List<BoxShadow> dialogShadow = [lg];
  static const List<BoxShadow> menuShadow = [md];
  static const List<BoxShadow> appBarShadow = [md];

  // Colored shadows
  static BoxShadow colored(Color color, {double opacity = 0.3}) {
    return BoxShadow(
      color: color.withOpacity(opacity),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    );
  }

  // Glow effects
  static BoxShadow glow(Color color, {double opacity = 0.4, double blur = 20}) {
    return BoxShadow(
      color: color.withOpacity(opacity),
      offset: Offset.zero,
      blurRadius: blur,
      spreadRadius: 0,
    );
  }

  // Helper method to get shadow by elevation
  static List<BoxShadow> elevation(double elevation) {
    if (elevation <= 0) return const [];
    if (elevation <= 1) return [xs];
    if (elevation <= 2) return [sm];
    if (elevation <= 4) return [md];
    if (elevation <= 8) return [lg];
    return [xl];
  }
}