import 'package:flutter/material.dart';
import 'package:nexlinks/core/widgets/common/tactile_feedback.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class EditProfileHeader extends StatelessWidget {
  const EditProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: [
          TactileFeedback(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  color: Theme.of(context).colorScheme.primary, size: 20),
            ),
          ),
          Expanded(
            child: Center(
              child: AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    "Edit Profile",
                    textStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    speed: const Duration(milliseconds: 100),
                  ),
                ],
                totalRepeatCount: 1,
              ),
            ),
          ),
          const SizedBox(width: 40), // Balance the row
        ],
      ),
    );
  }
}
