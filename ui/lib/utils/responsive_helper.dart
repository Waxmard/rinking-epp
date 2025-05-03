import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) => 
      MediaQuery.of(context).size.width < 600;
      
  static bool isTablet(BuildContext context) => 
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1000;
      
  static bool isDesktop(BuildContext context) => 
      MediaQuery.of(context).size.width >= 1000;
      
  static double getScreenWidth(BuildContext context) => 
      MediaQuery.of(context).size.width;
      
  static double getScreenHeight(BuildContext context) => 
      MediaQuery.of(context).size.height;
      
  // Get adaptive padding based on screen size
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }
  
  // Get adaptive font size based on screen size
  static double getAdaptiveFontSize(BuildContext context, double size) {
    if (isMobile(context)) {
      return size;
    } else if (isTablet(context)) {
      return size * 1.2;
    } else {
      return size * 1.5;
    }
  }
  
  // Return a value based on screen size
  static T valueBasedOnScreenSize<T>(
    BuildContext context, {
    required T mobile,
    required T tablet,
    required T desktop,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet;
    } else {
      return desktop;
    }
  }
  
  // Get responsive column count for grids
  static int getResponsiveGridCount(BuildContext context) {
    if (isMobile(context)) {
      return 2;
    } else if (isTablet(context)) {
      return 3;
    } else {
      return 4;
    }
  }
}