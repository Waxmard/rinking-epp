import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

/// Different styling options for the TierNerd text logo
class TierNerdLogoText {
  
  /// Option 1: Gradient with glow
  static Widget gradientGlow({double fontSize = 48}) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          Colors.white.withOpacity(0.9),
          AppColors.accent.withOpacity(0.8),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(bounds),
      child: Text(
        'TIERNERD',
        style: AppTypography.displayMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          letterSpacing: 3.0,
          fontSize: fontSize,
          height: 1.0,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
            Shadow(
              color: AppColors.accent.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 0),
            ),
          ],
        ),
      ),
    );
  }

  /// Option 2: Split style - "TIER" in one style, "NERD" in another
  static Widget splitStyle({double fontSize = 48}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'TIER',
          style: AppTypography.displayMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w300,
            letterSpacing: 2.0,
            fontSize: fontSize,
            height: 1.0,
          ),
        ),
        Text(
          'NERD',
          style: AppTypography.displayMedium.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontSize: fontSize,
            height: 1.0,
            shadows: [
              Shadow(
                color: AppColors.accent.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 0),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Option 3: Outlined text
  static Widget outlined({double fontSize = 48}) {
    return Stack(
      children: [
        // Outline
        Text(
          'TIERNERD',
          style: AppTypography.displayMedium.copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 3.0,
            height: 1.0,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = Colors.white,
          ),
        ),
        // Fill with gradient
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              AppColors.accent.withOpacity(0.3),
            ],
          ).createShader(bounds),
          child: Text(
            'TIERNERD',
            style: AppTypography.displayMedium.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: 3.0,
              height: 1.0,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  /// Option 4: Tier list inspired - colorful blocks
  static Widget tierBlocks({double fontSize = 48}) {
    final letters = 'TIERNERD'.split('');
    final colors = [
      AppColors.tierS,
      AppColors.tierA,
      AppColors.tierB,
      AppColors.tierC,
      AppColors.tierS,
      AppColors.tierA,
      AppColors.tierB,
      AppColors.tierD,
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(letters.length, (index) {
        return Container(
          margin: EdgeInsets.only(right: index < letters.length - 1 ? 2 : 0),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: colors[index].withOpacity(0.9),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: colors[index].withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            letters[index],
            style: AppTypography.displayMedium.copyWith(
              fontSize: fontSize * 0.8,
              fontWeight: FontWeight.w900,
              color: AppColors.getContrastText(colors[index]),
              height: 1.2,
            ),
          ),
        );
      }),
    );
  }

  /// Option 5: Neon glow effect
  static Widget neonGlow({double fontSize = 48}) {
    return Stack(
      children: [
        // Outer glow
        Text(
          'TIERNERD',
          style: AppTypography.displayMedium.copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 3.0,
            height: 1.0,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 6
              ..color = AppColors.accent.withOpacity(0.5)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
          ),
        ),
        // Inner glow
        Text(
          'TIERNERD',
          style: AppTypography.displayMedium.copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 3.0,
            height: 1.0,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = AppColors.accent
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
          ),
        ),
        // Main text
        Text(
          'TIERNERD',
          style: AppTypography.displayMedium.copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 3.0,
            height: 1.0,
            color: Colors.white,
            shadows: [
              Shadow(
                color: AppColors.accent,
                blurRadius: 20,
                offset: const Offset(0, 0),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Option 6: Retro arcade style
  static Widget retroArcade({double fontSize = 48}) {
    return Stack(
      children: [
        // Shadow layer
        Text(
          'TIERNERD',
          style: AppTypography.displayMedium.copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 3.0,
            height: 1.0,
            color: Colors.black.withOpacity(0.5),
          ),
        ),
        // 3D effect layers
        for (int i = 5; i > 0; i--)
          Transform.translate(
            offset: Offset(-i.toDouble(), -i.toDouble()),
            child: Text(
              'TIERNERD',
              style: AppTypography.displayMedium.copyWith(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                letterSpacing: 3.0,
                height: 1.0,
                color: Color.lerp(
                  AppColors.primary,
                  AppColors.accent,
                  i / 5,
                ),
              ),
            ),
          ),
        // Top layer
        Transform.translate(
          offset: const Offset(-1, -1),
          child: Text(
            'TIERNERD',
            style: AppTypography.displayMedium.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              letterSpacing: 3.0,
              height: 1.0,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  /// Option 7: Minimal clean
  static Widget minimal({double fontSize = 48}) {
    return Text(
      'TierNerd',
      style: AppTypography.displayMedium.copyWith(
        fontSize: fontSize,
        fontWeight: FontWeight.w200,
        letterSpacing: 8.0,
        height: 1.0,
        color: Colors.white,
      ),
    );
  }

  /// Option 8: Badge style
  static Widget badge({double fontSize = 48}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: fontSize * 0.5,
        vertical: fontSize * 0.2,
      ),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(fontSize * 0.15),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Text(
        'TIERNERD',
        style: AppTypography.displayMedium.copyWith(
          fontSize: fontSize * 0.8,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
          height: 1.0,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}