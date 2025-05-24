import 'package:flutter/material.dart';

/// Animation constants and curves
class AppAnimations {
  // Duration values
  static const Duration durationInstant = Duration(milliseconds: 0);
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Duration durationVerySlow = Duration(milliseconds: 800);

  // Curves
  static const Curve curveEaseIn = Curves.easeIn;
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveEaseInOut = Curves.easeInOut;
  static const Curve curveFastOutSlowIn = Curves.fastOutSlowIn;
  static const Curve curveLinear = Curves.linear;
  static const Curve curveBounce = Curves.bounceOut;
  static const Curve curveElastic = Curves.elasticOut;
  static const Curve curveOvershoot = Curves.easeOutBack;

  // Page transitions
  static const Duration pageTransitionDuration = durationNormal;
  static const Curve pageTransitionCurve = curveFastOutSlowIn;

  // Component-specific durations
  static const Duration buttonPressDuration = durationFast;
  static const Duration cardHoverDuration = durationFast;
  static const Duration dialogDuration = durationNormal;
  static const Duration snackbarDuration = Duration(seconds: 4);
  static const Duration tooltipDuration = durationFast;
  static const Duration expandCollapseDuration = durationNormal;

  // Pre-configured page routes
  static PageRouteBuilder<T> fadeRoute<T>({
    required Widget Function(BuildContext, Animation<double>, Animation<double>) pageBuilder,
    Duration duration = pageTransitionDuration,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: pageBuilder,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  static PageRouteBuilder<T> slideRoute<T>({
    required Widget page,
    Duration duration = pageTransitionDuration,
    Offset beginOffset = const Offset(1.0, 0.0),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(begin: beginOffset, end: Offset.zero)
            .chain(CurveTween(curve: pageTransitionCurve));
        
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  static PageRouteBuilder<T> scaleRoute<T>({
    required Widget page,
    Duration duration = pageTransitionDuration,
    double beginScale = 0.0,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(begin: beginScale, end: 1.0)
            .chain(CurveTween(curve: pageTransitionCurve));
        
        return ScaleTransition(
          scale: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  // Stagger animation helpers
  static Duration staggerDelay(int index, {Duration delay = const Duration(milliseconds: 50)}) {
    return delay * index;
  }

  static List<Animation<double>> createStaggeredAnimations(
    AnimationController controller,
    int count, {
    Duration itemDelay = const Duration(milliseconds: 50),
    Curve curve = curveFastOutSlowIn,
  }) {
    return List.generate(count, (index) {
      final start = (index * itemDelay.inMilliseconds) / controller.duration!.inMilliseconds;
      final end = start + 0.5;
      
      return Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: curve),
        ),
      );
    });
  }
}