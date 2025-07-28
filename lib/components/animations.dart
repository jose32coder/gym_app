import 'package:flutter/animation.dart';

class CustomAnimations {
  // Fade genérico
  static Animation<double> fadeIn(AnimationController controller,
      {double begin = 0,
      double end = 1,
      double start = 0,
      double finish = 1,
      Curve curve = Curves.easeInOut}) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(start, finish, curve: curve),
      ),
    );
  }

  // Slide desde la izquierda (x negativo)
  static Animation<Offset> slideFromLeft(AnimationController controller,
      {double start = 0, double finish = 1, Curve curve = Curves.easeOut}) {
    return Tween<Offset>(begin: const Offset(-1.0, 0), end: Offset.zero)
        .animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(start, finish, curve: curve),
      ),
    );
  }

  // Slide desde la derecha (x positivo)
  static Animation<Offset> slideFromRight(AnimationController controller,
      {double start = 0, double finish = 1, Curve curve = Curves.easeOut}) {
    return Tween<Offset>(begin: const Offset(1.0, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(start, finish, curve: curve),
      ),
    );
  }

  // Slide desde abajo (y positivo)
  static Animation<Offset> slideFromBottom(AnimationController controller,
      {double start = 0,
      double finish = 1,
      Curve curve = Curves.easeOutCubic}) {
    return Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(start, finish, curve: curve),
      ),
    );
  }

  // Animaciones de fade + slide customizados

  static Animation<double> fadeAnimation(AnimationController controller,
      {double start = 0, double finish = 0.4}) {
    return fadeIn(controller,
        start: start, finish: finish, curve: Curves.easeInOutCubic);
  }

  static Animation<Offset> slideAnimation(AnimationController controller,
      {double start = 0, double finish = 0.4}) {
    return slideFromBottom(controller,
        start: start, finish: finish, curve: Curves.easeOutCubic);
  }

  static Animation<double> fadeAnimationMovimientos(
      AnimationController controller,
      {double start = 0.5,
      double finish = 1.0}) {
    return fadeIn(controller,
        start: start, finish: finish, curve: Curves.easeInOutCubic);
  }

  static Animation<Offset> slideAnimationMovimientos(
      AnimationController controller,
      {double start = 0.5,
      double finish = 1.0}) {
    return slideFromBottom(controller,
        start: start, finish: finish, curve: Curves.easeOutCubic);
  }

  static Animation<double> fadeAnimation2(AnimationController controller,
      {double start = 0.8, double finish = 1.0}) {
    return fadeIn(controller,
        start: start, finish: finish, curve: Curves.easeInOutCubic);
  }

  static Animation<Offset> slideAnimation2(AnimationController controller,
      {double start = 0.8, double finish = 1.0}) {
    return slideFromBottom(controller,
        start: start, finish: finish, curve: Curves.easeOutCubic);
  }

  // Método para generar lista de animaciones slide escalonadas
  static List<Animation<Offset>> generateSlideAnimations(
      AnimationController controller, int itemCount,
      {double step = 0.15,
      double duration = 0.5,
      Curve curve = Curves.easeOut}) {
    return List.generate(itemCount, (index) {
      final start = index * step;
      final finish = start + duration;
      return slideFromBottom(
        controller,
        start: start,
        finish: finish,
        curve: curve,
      );
    });
  }

  // Método para generar lista de animaciones fade escalonadas
  static List<Animation<double>> generateFadeAnimations(
      AnimationController controller, int itemCount,
      {double step = 0.15,
      double duration = 0.5,
      Curve curve = Curves.easeIn}) {
    return List.generate(itemCount, (index) {
      final start = index * step;
      final finish = start + duration;
      return fadeIn(
        controller,
        start: start,
        finish: finish,
        curve: curve,
      );
    });
  }
}
