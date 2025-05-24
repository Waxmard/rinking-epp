import 'package:flutter/material.dart';
import 'colors.dart';

/// Border radius and width system
class AppBorders {
  // Border radius values
  static const double radiusNone = 0.0;
  static const double radiusXs = 2.0;
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusXxl = 24.0;
  static const double radiusFull = 9999.0;

  // Border width values
  static const double widthNone = 0.0;
  static const double widthThin = 1.0;
  static const double widthMedium = 2.0;
  static const double widthThick = 4.0;

  // Pre-defined BorderRadius
  static const BorderRadius none = BorderRadius.zero;
  static const BorderRadius xs = BorderRadius.all(Radius.circular(radiusXs));
  static const BorderRadius sm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius md = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius xl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius xxl = BorderRadius.all(Radius.circular(radiusXxl));
  static const BorderRadius full = BorderRadius.all(Radius.circular(radiusFull));

  // Partial BorderRadius
  static const BorderRadius topMd = BorderRadius.only(
    topLeft: Radius.circular(radiusMd),
    topRight: Radius.circular(radiusMd),
  );

  static const BorderRadius bottomMd = BorderRadius.only(
    bottomLeft: Radius.circular(radiusMd),
    bottomRight: Radius.circular(radiusMd),
  );

  static const BorderRadius leftMd = BorderRadius.only(
    topLeft: Radius.circular(radiusMd),
    bottomLeft: Radius.circular(radiusMd),
  );

  static const BorderRadius rightMd = BorderRadius.only(
    topRight: Radius.circular(radiusMd),
    bottomRight: Radius.circular(radiusMd),
  );

  // Pre-defined borders
  static const Border noBorder = Border();
  
  static const Border thin = Border(
    top: BorderSide(color: AppColors.divider, width: widthThin),
    bottom: BorderSide(color: AppColors.divider, width: widthThin),
    left: BorderSide(color: AppColors.divider, width: widthThin),
    right: BorderSide(color: AppColors.divider, width: widthThin),
  );

  static const Border medium = Border(
    top: BorderSide(color: AppColors.divider, width: widthMedium),
    bottom: BorderSide(color: AppColors.divider, width: widthMedium),
    left: BorderSide(color: AppColors.divider, width: widthMedium),
    right: BorderSide(color: AppColors.divider, width: widthMedium),
  );

  // Border sides
  static const BorderSide thinSide = BorderSide(
    color: AppColors.divider,
    width: widthThin,
  );

  static const BorderSide mediumSide = BorderSide(
    color: AppColors.divider,
    width: widthMedium,
  );

  static const BorderSide thickSide = BorderSide(
    color: AppColors.divider,
    width: widthThick,
  );

  // Outline input borders
  static OutlineInputBorder outlineInput({
    Color color = AppColors.divider,
    double width = widthThin,
    double radius = radiusMd,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static OutlineInputBorder outlineInputFocused({
    Color color = AppColors.primary,
    double width = widthMedium,
    double radius = radiusMd,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static OutlineInputBorder outlineInputError({
    Color color = AppColors.error,
    double width = widthMedium,
    double radius = radiusMd,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  // Underline input borders
  static UnderlineInputBorder underlineInput({
    Color color = AppColors.divider,
    double width = widthThin,
  }) {
    return UnderlineInputBorder(
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static UnderlineInputBorder underlineInputFocused({
    Color color = AppColors.primary,
    double width = widthMedium,
  }) {
    return UnderlineInputBorder(
      borderSide: BorderSide(color: color, width: width),
    );
  }
}