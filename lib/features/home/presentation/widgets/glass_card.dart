import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: width,
            height: height,
            padding: padding,
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color!.withOpacity(0.6),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white.withOpacity(0.05)
                    : Colors.white.withOpacity(0.4),
                width: 1,
              ),
              boxShadow: [
                // Bottom-Right Dark Shadow (Depth)
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.black.withOpacity(0.6) 
                      : const Color(0xFFA3B1C6).withOpacity(0.5),
                  blurRadius: 24,
                  spreadRadius: 1,
                  offset: const Offset(10, 10),
                ),
                // Top-Left Light Shadow (Highlight)
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white.withOpacity(0.05) 
                      : Colors.white,
                  blurRadius: 24,
                  spreadRadius: 1,
                  offset: const Offset(-8, -8),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
