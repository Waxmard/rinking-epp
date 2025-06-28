import 'package:flutter/material.dart';
import '../tokens/tokens.dart';

/// Card variants following the design system
class AppCard extends StatelessWidget {
  final Widget child;
  final AppCardVariant variant;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final Color? color;
  final double? width;
  final double? height;

  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.elevated,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = color ?? (isDark ? AppColors.cardDark : AppColors.cardLight);
    
    Widget content = Container(
      width: width,
      height: height,
      padding: padding ?? EdgeInsets.all(AppSpacing.cardPadding),
      child: child,
    );

    BoxDecoration decoration;
    switch (variant) {
      case AppCardVariant.elevated:
        decoration = BoxDecoration(
          color: cardColor,
          borderRadius: AppBorders.md,
          boxShadow: AppShadows.cardShadow,
        );
        break;
      
      case AppCardVariant.filled:
        decoration = BoxDecoration(
          color: cardColor,
          borderRadius: AppBorders.md,
        );
        break;
      
      case AppCardVariant.outlined:
        decoration = BoxDecoration(
          color: cardColor,
          borderRadius: AppBorders.md,
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.divider,
            width: AppBorders.widthThin,
          ),
        );
        break;
      
      case AppCardVariant.ghost:
        decoration = BoxDecoration(
          color: Colors.transparent,
          borderRadius: AppBorders.md,
        );
        break;
    }

    Widget card = Container(
      margin: margin ?? EdgeInsets.all(AppSpacing.sm),
      decoration: decoration,
      child: content,
    );

    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppBorders.md,
          child: card,
        ),
      );
    }

    return card;
  }
}

enum AppCardVariant {
  elevated,
  filled,
  outlined,
  ghost,
}

/// Specialized list item card
class AppListCard extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final bool dense;

  const AppListCard({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? 
        EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: dense ? AppSpacing.sm : AppSpacing.md,
        );

    return AppCard(
      variant: AppCardVariant.elevated,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Padding(
        padding: effectivePadding,
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: dense ? AppTypography.bodyMedium : AppTypography.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: dense ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              SizedBox(width: AppSpacing.md),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Tier card component
class AppTierCard extends StatelessWidget {
  final String tier;
  final String? label;
  final List<Widget> children;
  final double? height;
  final EdgeInsets? padding;

  const AppTierCard({
    super.key,
    required this.tier,
    this.label,
    required this.children,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final tierColor = AppColors.getTierColor(tier);
    final textColor = AppColors.getContrastText(tierColor);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: tierColor,
        borderRadius: AppBorders.md,
        boxShadow: [AppShadows.colored(tierColor, opacity: 0.2)],
      ),
      child: Row(
        children: [
          // Tier label
          Container(
            width: 60,
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: tierColor.withOpacity(0.2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppBorders.radiusMd),
                bottomLeft: Radius.circular(AppBorders.radiusMd),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  tier,
                  style: AppTypography.headlineLarge.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (label != null) ...[
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    label!,
                    style: AppTypography.labelSmall.copyWith(
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Items
          Expanded(
            child: Container(
              padding: padding ?? EdgeInsets.all(AppSpacing.sm),
              child: children.isEmpty
                  ? Center(
                      child: Text(
                        'Drop items here',
                        style: AppTypography.bodyMedium.copyWith(
                          color: textColor.withOpacity(0.5),
                        ),
                      ),
                    )
                  : Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: children,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}