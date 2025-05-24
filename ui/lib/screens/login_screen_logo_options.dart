import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

/// Different creative approaches for displaying the logo
class LogoDisplayOptions {
  
  /// Option 1: White circular background with shadow
  static Widget circularBackground({double size = 200}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          AppShadows.glow(Colors.white, opacity: 0.3, blur: 30),
          AppShadows.lg,
        ],
      ),
      padding: EdgeInsets.all(size * 0.1), // 10% padding
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo-transparent.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  /// Option 2: Gradient fade effect
  static Widget gradientFade({double size = 200}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Gradient overlay
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.transparent,
                AppColors.primary.withOpacity(0.3),
                AppColors.primary,
              ],
              stops: const [0.5, 0.8, 1.0],
            ),
          ),
        ),
        // Logo
        Image.asset(
          'assets/images/logo-transparent.png',
          width: size * 0.8,
          height: size * 0.8,
          fit: BoxFit.contain,
        ),
      ],
    );
  }

  /// Option 3: Glass morphism effect - Enhanced for transparent logo
  static Widget glassMorphism({double size = 200}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(size * 0.2),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          AppShadows.glow(Colors.white, opacity: 0.3, blur: 30),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.2),
        child: BackdropFilter(
          filter: ColorFilter.mode(
            Colors.white.withOpacity(0.1),
            BlendMode.srcOver,
          ),
          child: Padding(
            padding: EdgeInsets.all(size * 0.08),
            child: Image.asset(
              'assets/images/logo-transparent.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  /// Option 4: Hexagonal shape (modern look)
  static Widget hexagonShape({double size = 200}) {
    return CustomPaint(
      size: Size(size, size),
      painter: HexagonPainter(
        color: Colors.white,
        shadowColor: Colors.white.withOpacity(0.3),
      ),
      child: Container(
        padding: EdgeInsets.all(size * 0.15),
        child: Image.asset(
          'assets/images/logo-transparent.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  /// Option 5: Blend mode (if logo has transparency)
  static Widget blendMode({double size = 200}) {
    return Container(
      width: size,
      height: size,
      child: Stack(
        children: [
          // White glow background
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                AppShadows.glow(Colors.white, opacity: 0.4, blur: 40),
              ],
            ),
          ),
          // Logo with blend mode
          Center(
            child: Container(
              width: size,
              height: size,
              child: Image.asset(
                'assets/images/logo-transparent.png',
                fit: BoxFit.contain,
                color: Colors.white,
                colorBlendMode: BlendMode.multiply,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Option 6: Animated glow effect - Perfect for transparent logos
  static Widget animatedGlow({
    double size = 200,
    required Animation<double> animation,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Animated glow background
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2 + (0.3 * animation.value)),
                    blurRadius: 30 + (30 * animation.value),
                    spreadRadius: 10 * animation.value,
                  ),
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.1 + (0.1 * animation.value)),
                    blurRadius: 50 + (20 * animation.value),
                    spreadRadius: 15 * animation.value,
                  ),
                ],
              ),
            ),
            // Logo with subtle scale animation
            Transform.scale(
              scale: 1.0 + (0.05 * animation.value),
              child: child!,
            ),
          ],
        );
      },
      child: Image.asset(
        'assets/images/logo-transparent.png',
        fit: BoxFit.contain,
      ),
    );
  }
}

/// Custom painter for hexagon shape
class HexagonPainter extends CustomPainter {
  final Color color;
  final Color shadowColor;

  HexagonPainter({
    required this.color,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    final path = Path();
    final width = size.width;
    final height = size.height;

    // Create hexagon path
    path.moveTo(width * 0.5, 0);
    path.lineTo(width * 0.85, height * 0.25);
    path.lineTo(width * 0.85, height * 0.75);
    path.lineTo(width * 0.5, height);
    path.lineTo(width * 0.15, height * 0.75);
    path.lineTo(width * 0.15, height * 0.25);
    path.close();

    // Draw shadow
    canvas.drawPath(path, shadowPaint);
    // Draw hexagon
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}