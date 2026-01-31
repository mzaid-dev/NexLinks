import 'dart:async';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AppLoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;
  final bool isFullScreen;
  final bool showTimeoutMessage;

  const AppLoadingIndicator({
    super.key,
    this.size = 40,
    this.color,
    this.isFullScreen = true,
    this.showTimeoutMessage = true,
  });

  @override
  State<AppLoadingIndicator> createState() => _AppLoadingIndicatorState();
}

class _AppLoadingIndicatorState extends State<AppLoadingIndicator> {
  bool _showTakingLong = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 7), () {
      if (mounted) {
        setState(() => _showTakingLong = true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingAnimationWidget.staggeredDotsWave(
            color: widget.color ?? Theme.of(context).colorScheme.primary,
            size: widget.size,
          ),
          if (_showTakingLong && widget.showTimeoutMessage) ...[
            const SizedBox(height: 24),
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 500),
              child: Column(
                children: [
                  Text(
                    "Taking a bit long...",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Please check your internet connection.",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );

    if (widget.isFullScreen) {
      return SizedBox.expand(child: content);
    }
    return content;
  }
}
