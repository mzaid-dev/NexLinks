import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:nexlinks/core/widgets/common/app_button.dart';

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
      ],
    );
  }
}
