import 'package:flutter/material.dart';
import '../tokens/tokens.dart';

/// Text field following the design system
class AppTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool autofocus;
  final int? maxLines;
  final Widget? prefix;
  final Widget? suffix;
  final bool enabled;
  final FocusNode? focusNode;

  const AppTextField({
    Key? key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.onChanged,
    this.onEditingComplete,
    this.keyboardType,
    this.obscureText = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.prefix,
    this.suffix,
    this.enabled = true,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTypography.labelMedium.copyWith(
              color: hasError 
                  ? AppColors.error 
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
            ),
          ),
          SizedBox(height: AppSpacing.xs),
        ],
        TextField(
          controller: controller,
          onChanged: onChanged,
          onEditingComplete: onEditingComplete,
          keyboardType: keyboardType,
          obscureText: obscureText,
          autofocus: autofocus,
          maxLines: maxLines,
          enabled: enabled,
          focusNode: focusNode,
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: isDark 
                  ? AppColors.textSecondaryDark.withOpacity(0.5)
                  : AppColors.textSecondary.withOpacity(0.7),
            ),
            errorText: errorText,
            errorStyle: AppTypography.bodySmall.copyWith(
              color: AppColors.error,
            ),
            prefixIcon: prefix,
            suffixIcon: suffix,
            filled: true,
            fillColor: isDark 
                ? AppColors.surfaceDark.withOpacity(0.5)
                : AppColors.surfaceLight,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            border: AppBorders.outlineInput(),
            enabledBorder: AppBorders.outlineInput(
              color: isDark ? AppColors.dividerDark : AppColors.divider,
            ),
            focusedBorder: AppBorders.outlineInputFocused(
              color: hasError ? AppColors.error : AppColors.primary,
            ),
            errorBorder: AppBorders.outlineInputError(),
            focusedErrorBorder: AppBorders.outlineInputError(),
            disabledBorder: AppBorders.outlineInput(
              color: isDark 
                  ? AppColors.dividerDark.withOpacity(0.5)
                  : AppColors.divider.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }
}

/// Dropdown following the design system
class AppDropdown<T> extends StatelessWidget {
  final String? label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hint;
  final Widget? prefix;
  final bool enabled;

  const AppDropdown({
    Key? key,
    this.label,
    this.value,
    required this.items,
    this.onChanged,
    this.hint,
    this.prefix,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTypography.labelMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
        ],
        Container(
          decoration: BoxDecoration(
            color: isDark 
                ? AppColors.surfaceDark.withOpacity(0.5)
                : AppColors.surfaceLight,
            borderRadius: AppBorders.md,
            border: Border.all(
              color: isDark ? AppColors.dividerDark : AppColors.divider,
              width: AppBorders.widthThin,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: enabled ? onChanged : null,
              hint: hint != null
                  ? Text(
                      hint!,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark 
                            ? AppColors.textSecondaryDark.withOpacity(0.5)
                            : AppColors.textSecondary.withOpacity(0.7),
                      ),
                    )
                  : null,
              icon: Icon(
                Icons.arrow_drop_down,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
              isExpanded: true,
              borderRadius: AppBorders.md,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Switch following the design system
class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final bool enabled;

  const AppSwitch({
    Key? key,
    required this.value,
    this.onChanged,
    this.label,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget switchWidget = Switch(
      value: value,
      onChanged: enabled ? onChanged : null,
      activeColor: AppColors.accent,
      activeTrackColor: AppColors.accent.withOpacity(0.5),
      inactiveThumbColor: AppColors.neutral[400],
      inactiveTrackColor: AppColors.neutral[300],
    );

    if (label == null) {
      return switchWidget;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Text(
            label!,
            style: AppTypography.bodyMedium,
          ),
        ),
        switchWidget,
      ],
    );
  }
}

/// Checkbox following the design system
class AppCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final String? label;
  final bool enabled;

  const AppCheckbox({
    Key? key,
    required this.value,
    this.onChanged,
    this.label,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget checkbox = Checkbox(
      value: value,
      onChanged: enabled ? onChanged : null,
      activeColor: AppColors.primary,
      checkColor: AppColors.textOnPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorders.xs,
      ),
    );

    if (label == null) {
      return checkbox;
    }

    return InkWell(
      onTap: enabled 
          ? () => onChanged?.call(!value)
          : null,
      borderRadius: AppBorders.sm,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          checkbox,
          SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              label!,
              style: AppTypography.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}