import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback onGooglePressed;
  final VoidCallback onFacebookPressed;

  const SocialLoginButtons({
    super.key,
    required this.onGooglePressed,
    required this.onFacebookPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FadeInUp(
          duration: const Duration(milliseconds: 800),
          delay: const Duration(milliseconds: 700),
          child: _SocialButton(
            text: "Continue with Google",
            icon: Icons.g_mobiledata_rounded,
            color: Colors.white,
            textColor: Colors.black,
            onPressed: onGooglePressed,
          ),
        ),
        const SizedBox(height: 16),
        // FadeInUp(
        //   duration: const Duration(milliseconds: 800),
        //   delay: const Duration(milliseconds: 800),
        //   child: _SocialButton(
        //     text: "Continue with Facebook",
        //     icon: Icons.facebook_rounded,
        //     color: const Color(0xFF1877F2),
        //     textColor: Colors.white,
        //     onPressed: onFacebookPressed,
        //   ),
        // ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.text,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 28),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
