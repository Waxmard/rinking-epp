import 'package:flutter/material.dart';
import '../tokens/tokens.dart';

/// Centralized theme configuration using the design system
class AppTheme {
  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Colors
      primaryColor: AppColors.primary,
      primaryColorLight: AppColors.primary[300],
      primaryColorDark: AppColors.primary[700],
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        error: AppColors.error,
        surface: AppColors.surfaceLight,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnAccent,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textOnPrimary,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: AppColors.backgroundLight,
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: AppShadows.elevationMd,
        centerTitle: false,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.textOnPrimary,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textOnPrimary,
        ),
      ),
      
      // Card
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: AppShadows.elevationSm,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorders.md,
        ),
        margin: EdgeInsets.all(AppSpacing.sm),
      ),
      
      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.neutral[300],
          disabledForegroundColor: AppColors.textDisabled,
          elevation: AppShadows.elevationXs,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorders.md,
          ),
          textStyle: AppTypography.button,
        ),
      ),
      
      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textDisabled,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorders.md,
          ),
          textStyle: AppTypography.button,
        ),
      ),
      
      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textDisabled,
          side: const BorderSide(
            color: AppColors.primary,
            width: AppBorders.widthMedium,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorders.md,
          ),
          textStyle: AppTypography.button,
        ),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: AppBorders.outlineInput(),
        enabledBorder: AppBorders.outlineInput(),
        focusedBorder: AppBorders.outlineInputFocused(),
        errorBorder: AppBorders.outlineInputError(),
        focusedErrorBorder: AppBorders.outlineInputError(),
        labelStyle: AppTypography.labelMedium,
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary.withOpacity(0.7),
        ),
        errorStyle: AppTypography.bodySmall.copyWith(
          color: AppColors.error,
        ),
      ),
      
      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textOnAccent,
        elevation: AppShadows.elevationMd,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorders.full,
        ),
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: AppBorders.widthThin,
        space: AppSpacing.md,
      ),
      
      // Typography
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        displaySmall: AppTypography.displaySmall,
        headlineLarge: AppTypography.headlineLarge,
        headlineMedium: AppTypography.headlineMedium,
        headlineSmall: AppTypography.headlineSmall,
        titleLarge: AppTypography.titleLarge,
        titleMedium: AppTypography.titleMedium,
        titleSmall: AppTypography.titleSmall,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: 24,
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.neutral[200]!,
        deleteIconColor: AppColors.textSecondary,
        disabledColor: AppColors.neutral[300]!,
        selectedColor: AppColors.primary,
        secondarySelectedColor: AppColors.accent,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        labelStyle: AppTypography.labelMedium,
        secondaryLabelStyle: AppTypography.labelMedium,
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorders.full,
          side: BorderSide.none,
        ),
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Colors
      primaryColor: AppColors.primary,
      primaryColorLight: AppColors.primary[300],
      primaryColorDark: AppColors.primary[700],
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        error: AppColors.error,
        surface: AppColors.surfaceDark,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnAccent,
        onSurface: AppColors.textPrimaryDark,
        onError: AppColors.textOnPrimary,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: AppColors.backgroundDark,
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textPrimaryDark,
        ),
      ),
      
      // Card
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: AppShadows.elevationSm,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorders.md,
        ),
        margin: EdgeInsets.all(AppSpacing.sm),
      ),
      
      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary[400],
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.neutral[700],
          disabledForegroundColor: AppColors.textDisabledDark,
          elevation: AppShadows.elevationXs,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorders.md,
          ),
          textStyle: AppTypography.button,
        ),
      ),
      
      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary[300],
          disabledForegroundColor: AppColors.textDisabledDark,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorders.md,
          ),
          textStyle: AppTypography.button,
        ),
      ),
      
      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary[300],
          disabledForegroundColor: AppColors.textDisabledDark,
          side: BorderSide(
            color: AppColors.primary[300]!,
            width: AppBorders.widthMedium,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorders.md,
          ),
          textStyle: AppTypography.button,
        ),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark.withOpacity(0.5),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: AppBorders.outlineInput(color: AppColors.dividerDark),
        enabledBorder: AppBorders.outlineInput(color: AppColors.dividerDark),
        focusedBorder: AppBorders.outlineInputFocused(color: AppColors.accent),
        errorBorder: AppBorders.outlineInputError(),
        focusedErrorBorder: AppBorders.outlineInputError(),
        labelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondaryDark.withOpacity(0.5),
        ),
        errorStyle: AppTypography.bodySmall.copyWith(
          color: AppColors.error,
        ),
      ),
      
      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textOnAccent,
        elevation: AppShadows.elevationMd,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorders.full,
        ),
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
        thickness: AppBorders.widthThin,
        space: AppSpacing.md,
      ),
      
      // Typography
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(color: AppColors.textPrimaryDark),
        displayMedium: AppTypography.displayMedium.copyWith(color: AppColors.textPrimaryDark),
        displaySmall: AppTypography.displaySmall.copyWith(color: AppColors.textPrimaryDark),
        headlineLarge: AppTypography.headlineLarge.copyWith(color: AppColors.textPrimaryDark),
        headlineMedium: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimaryDark),
        headlineSmall: AppTypography.headlineSmall.copyWith(color: AppColors.textPrimaryDark),
        titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.textPrimaryDark),
        titleMedium: AppTypography.titleMedium.copyWith(color: AppColors.textPrimaryDark),
        titleSmall: AppTypography.titleSmall.copyWith(color: AppColors.textPrimaryDark),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimaryDark),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
        bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.textSecondaryDark),
        labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.textPrimaryDark),
        labelMedium: AppTypography.labelMedium.copyWith(color: AppColors.textPrimaryDark),
        labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.textSecondaryDark),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.textPrimaryDark,
        size: 24,
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.neutral[700]!,
        deleteIconColor: AppColors.textSecondaryDark,
        disabledColor: AppColors.neutral[800]!,
        selectedColor: AppColors.primary[600],
        secondarySelectedColor: AppColors.accent[600],
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        labelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        secondaryLabelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorders.full,
          side: BorderSide.none,
        ),
      ),
    );
  }
}