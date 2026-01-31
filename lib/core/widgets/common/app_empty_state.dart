import 'package:chat_app/core/widgets/common/app_button.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onAction;
  final String? actionLabel;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeInUp(
        duration: const Duration(milliseconds: 600),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              if (onAction != null && actionLabel != null) ...[
                const SizedBox(height: 32),
                AppButton(
                  text: actionLabel!,
                  onPressed: onAction,
                  width: 200,
                  style: AppButtonStyle.primary,
                  height: 48,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
