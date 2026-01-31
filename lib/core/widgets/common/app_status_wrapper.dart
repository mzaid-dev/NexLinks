import 'dart:io';
import 'package:flutter/material.dart';
import 'package:chat_app/core/services/error_handler.dart';
import 'package:chat_app/core/widgets/common/app_loading_indicator.dart';

class AppStatusWrapper extends StatelessWidget {
  final bool isLoading;
  final dynamic error;
  final bool isEmpty;
  final Widget child;
  final VoidCallback? onRetry;
  final String emptyMessage;

  const AppStatusWrapper({
    super.key,
    required this.child,
    this.isLoading = false,
    this.error,
    this.isEmpty = false,
    this.onRetry,
    this.emptyMessage = "No data found",
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const AppLoadingIndicator();
    }

    if (error != null) {
      final isNetworkError = error is SocketException;
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isNetworkError ? Icons.wifi_off_rounded : Icons.error_outline_rounded, 
                  color: Theme.of(context).colorScheme.error.withValues(alpha: 0.7), 
                  size: 48,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                ErrorHandler.getMessage(error),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8), 
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    side: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text("Try Again", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_mosaic_rounded, 
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15), 
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), 
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return child;
  }
}
