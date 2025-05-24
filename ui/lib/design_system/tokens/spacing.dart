import 'package:flutter/material.dart';

/// Spacing tokens following an 8-point grid system
/// These values ensure consistent spacing throughout the app
class AppSpacing {
  // Base unit - all spacing values are multiples of this
  static const double unit = 8.0;

  // Spacing scale
  static const double xxs = 2.0;   // 0.25 * unit
  static const double xs = 4.0;    // 0.5 * unit
  static const double sm = 8.0;    // 1 * unit
  static const double md = 16.0;   // 2 * unit
  static const double lg = 24.0;   // 3 * unit
  static const double xl = 32.0;   // 4 * unit
  static const double xxl = 48.0;  // 6 * unit
  static const double xxxl = 64.0; // 8 * unit

  // Component-specific spacing
  static const double cardPadding = md;
  static const double screenPadding = md;
  static const double sectionSpacing = lg;
  static const double itemSpacing = sm;
  static const double buttonPadding = md;
  static const double iconSpacing = sm;

  // Layout spacing
  static const double gridGap = md;
  static const double listItemGap = sm;
  static const double formFieldGap = md;

  // Safe area padding
  static const EdgeInsets safeArea = EdgeInsets.all(md);
  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets screenVertical = EdgeInsets.symmetric(vertical: md);

  // Helper method to get responsive spacing
  static double responsive(BuildContext context, {
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

/// Extension methods for convenient spacing widgets
extension SpacingWidgetExtension on double {
  Widget get horizontal => SizedBox(width: this);
  Widget get vertical => SizedBox(height: this);
}

/// Extension methods for convenient EdgeInsets
extension SpacingEdgeInsetsExtension on double {
  EdgeInsets get all => EdgeInsets.all(this);
  EdgeInsets get horizontalPadding => EdgeInsets.symmetric(horizontal: this);
  EdgeInsets get verticalPadding => EdgeInsets.symmetric(vertical: this);
  EdgeInsets get left => EdgeInsets.only(left: this);
  EdgeInsets get right => EdgeInsets.only(right: this);
  EdgeInsets get top => EdgeInsets.only(top: this);
  EdgeInsets get bottom => EdgeInsets.only(bottom: this);
}