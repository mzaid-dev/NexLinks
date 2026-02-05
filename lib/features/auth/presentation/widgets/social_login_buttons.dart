import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:nexlinks/core/widgets/common/app_button.dart';
import 'package:flutter/foundation.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback onGooglePressed;
  final VoidCallback onFacebookPressed;
  final VoidCallback? onApplePressed;

  const SocialLoginButtons({
    super.key,
    required this.onGooglePressed,
    required this.onFacebookPressed,
    this.onApplePressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSupportedPlatform =
        kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;

    if (!isSupportedPlatform) return const SizedBox.shrink();

    return Column(
      children: [
        FadeInUp(
          duration: const Duration(milliseconds: 800),
          delay: const Duration(milliseconds: 700),
          child: AppButton(
            text: "Continue with Google",
            icon: Icons.g_mobiledata_rounded,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            onPressed: onGooglePressed,
            style: AppButtonStyle.outlined,
            height: 56,
          ),
        ),
        const SizedBox(height: 16),
        if (defaultTargetPlatform == TargetPlatform.iOS)
          FadeInUp(
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 800),
            child: AppButton(
              text: "Continue with Apple",
              icon: Icons.apple,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              onPressed: onApplePressed ?? () {},
              style: AppButtonStyle.filled,
              height: 56,
            ),
          ),
      ],
    );
  }
}
