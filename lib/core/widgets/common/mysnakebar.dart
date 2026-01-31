import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

class MySnackBar {
  static void show({
    required BuildContext context,
    required String message,
    String? title,
    IconData? icon,
    bool isError = false,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 4),
    FlushbarPosition position = FlushbarPosition.TOP,
  }) {
    Flushbar(
      title: title,
      borderWidth: 1,
      isDismissible: true,
      message: message,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.only(left: 30,right: 30,top: 20,bottom: 20),
      borderRadius: BorderRadius.circular(18),
      backgroundColor: backgroundColor ??
          (isError ? Colors.red.shade700 : Colors.green.shade700),
      duration: duration,
      flushbarPosition: position,
      icon: Icon(
        icon ??
            (isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded),
        color: Colors.white,

        size: 42,
        fontWeight: FontWeight.w500,

      ),
      messageColor: textColor ?? Colors.white,
      titleColor: textColor ?? Colors.white,
      shouldIconPulse: true,
      boxShadows: [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.15),
          blurRadius: 20,
          offset: const Offset(0, 3),
        ),
      ],
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInCubic,
      animationDuration: const Duration(milliseconds: 600),
      onTap: (flushbar) {
        flushbar.dismiss();
      },
    ).show(context);
  }
}
