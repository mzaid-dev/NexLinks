import 'package:chiclet/chiclet.dart';
import 'package:flutter/material.dart';

enum AppButtonStyle { primary, secondary, outlined, danger }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonStyle style;
  final double? width;
  final double height;
  final double borderRadius;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = AppButtonStyle.primary,
    this.width,
    this.height = 56,
    this.borderRadius = 16,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color buttonColor;
    Color? shadowColor;
    Color contentColor = Colors.white;

    switch (style) {
      case AppButtonStyle.primary:
        buttonColor = const Color(0xFF2563EB); // Royal Blue
        shadowColor = const Color(0xFF1E40AF);
        break;
      case AppButtonStyle.secondary:
        buttonColor = const Color(0xFF22D3EE); // Cyan
        shadowColor = const Color(0xFF0891B2);
        break;
      case AppButtonStyle.outlined:
        buttonColor = Colors.white;
        shadowColor = Colors.grey[300];
        contentColor = colorScheme.primary;
        break;
      case AppButtonStyle.danger:
        buttonColor = Colors.redAccent;
        shadowColor = Colors.red[900];
        break;
    }

    if (backgroundColor != null) {
      buttonColor = backgroundColor!;
      // Auto-generate shadow color if not provided (darker version)
      shadowColor = HSLColor.fromColor(buttonColor).withLightness((HSLColor.fromColor(buttonColor).lightness - 0.15).clamp(0.0, 1.0)).toColor();
    }
    
    if (textColor != null) {
      contentColor = textColor!;
    }

    if (onPressed == null || isLoading) {
      buttonColor = buttonColor.withValues(alpha: 0.5);
      shadowColor = shadowColor?.withValues(alpha: 0.5);
    }

    return SizedBox(
      width: width ?? double.infinity,
      child: ChicletAnimatedButton(
        onPressed: isLoading ? () {} : onPressed,
        backgroundColor: buttonColor,
        buttonHeight: 4,
        borderRadius: borderRadius,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: textColor, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
