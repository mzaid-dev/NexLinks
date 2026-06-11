import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class SlideAnimation extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final double from;

  const SlideAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.delay = Duration.zero,
    this.from = 30,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: duration,
      delay: delay,
      from: from,
      child: child,
    );
  }
}
