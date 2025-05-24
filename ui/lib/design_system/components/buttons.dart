import 'package:flutter/material.dart';
import '../tokens/tokens.dart';

/// Button variants following the design system
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const AppButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    
    Widget child = isLoading
        ? SizedBox(
            width: _iconSize,
            height: _iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(_foregroundColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: _iconSize),
                SizedBox(width: AppSpacing.sm),
              ],
              Text(label, style: _textStyle),
            ],
          );

    Widget button;
    
    switch (variant) {
      case AppButtonVariant.primary:
        button = ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: _elevatedButtonStyle(context, AppColors.primary),
          child: child,
        );
        break;
      
      case AppButtonVariant.secondary:
        button = ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: _elevatedButtonStyle(context, AppColors.accent),
          child: child,
        );
        break;
      
      case AppButtonVariant.outline:
        button = OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: _outlinedButtonStyle(context),
          child: child,
        );
        break;
      
      case AppButtonVariant.text:
        button = TextButton(
          onPressed: isDisabled ? null : onPressed,
          style: _textButtonStyle(context),
          child: child,
        );
        break;
      
      case AppButtonVariant.danger:
        button = ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: _elevatedButtonStyle(context, AppColors.error),
          child: child,
        );
        break;
    }

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        height: _height,
        child: button,
      );
    }

    return button;
  }

  double get _height {
    switch (size) {
      case AppButtonSize.small:
        return 32.0;
      case AppButtonSize.medium:
        return 40.0;
      case AppButtonSize.large:
        return 48.0;
    }
  }

  double get _iconSize {
    switch (size) {
      case AppButtonSize.small:
        return 16.0;
      case AppButtonSize.medium:
        return 20.0;
      case AppButtonSize.large:
        return 24.0;
    }
  }

  EdgeInsets get _padding {
    switch (size) {
      case AppButtonSize.small:
        return EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs);
      case AppButtonSize.medium:
        return EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm);
      case AppButtonSize.large:
        return EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md);
    }
  }

  TextStyle get _textStyle {
    switch (size) {
      case AppButtonSize.small:
        return AppTypography.labelSmall;
      case AppButtonSize.medium:
        return AppTypography.labelMedium;
      case AppButtonSize.large:
        return AppTypography.labelLarge;
    }
  }

  Color get _foregroundColor {
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.secondary:
      case AppButtonVariant.danger:
        return AppColors.textOnPrimary;
      case AppButtonVariant.outline:
      case AppButtonVariant.text:
        return AppColors.primary;
    }
  }

  ButtonStyle _elevatedButtonStyle(BuildContext context, Color backgroundColor) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: _foregroundColor,
      disabledBackgroundColor: AppColors.neutral[300],
      disabledForegroundColor: AppColors.textDisabled,
      elevation: AppShadows.elevationXs,
      shadowColor: backgroundColor.withOpacity(0.3),
      padding: _padding,
      minimumSize: Size(0, _height),
      shape: RoundedRectangleBorder(
        borderRadius: AppBorders.md,
      ),
      textStyle: _textStyle,
    );
  }

  ButtonStyle _outlinedButtonStyle(BuildContext context) {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      disabledForegroundColor: AppColors.textDisabled,
      padding: _padding,
      minimumSize: Size(0, _height),
      side: BorderSide(
        color: AppColors.primary,
        width: AppBorders.widthMedium,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppBorders.md,
      ),
      textStyle: _textStyle,
    );
  }

  ButtonStyle _textButtonStyle(BuildContext context) {
    return TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      disabledForegroundColor: AppColors.textDisabled,
      padding: _padding,
      minimumSize: Size(0, _height),
      shape: RoundedRectangleBorder(
        borderRadius: AppBorders.md,
      ),
      textStyle: _textStyle,
    );
  }
}

enum AppButtonVariant {
  primary,
  secondary,
  outline,
  text,
  danger,
}

enum AppButtonSize {
  small,
  medium,
  large,
}

/// Icon button following the design system
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final AppIconButtonSize size;
  final Color? color;
  final Color? backgroundColor;
  final String? tooltip;

  const AppIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.size = AppIconButtonSize.medium,
    this.color,
    this.backgroundColor,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: backgroundColor ?? Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: EdgeInsets.all(_padding),
          child: Icon(
            icon,
            size: _iconSize,
            color: color ?? Theme.of(context).iconTheme.color,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }

  double get _iconSize {
    switch (size) {
      case AppIconButtonSize.small:
        return 16.0;
      case AppIconButtonSize.medium:
        return 20.0;
      case AppIconButtonSize.large:
        return 24.0;
    }
  }

  double get _padding {
    switch (size) {
      case AppIconButtonSize.small:
        return AppSpacing.xs;
      case AppIconButtonSize.medium:
        return AppSpacing.sm;
      case AppIconButtonSize.large:
        return AppSpacing.md;
    }
  }
}

enum AppIconButtonSize {
  small,
  medium,
  large,
}