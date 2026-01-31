import 'package:flutter/material.dart';

class PulsingStatus extends StatefulWidget {
  final Color color;
  final double size;

  const PulsingStatus({
    super.key,
    this.color = const Color(0xFF34C759),
    this.size = 12,
  });

  @override
  State<PulsingStatus> createState() => _PulsingStatusState();
}

class _PulsingStatusState extends State<PulsingStatus> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size + (widget.size * _animation.value * 0.8),
          height: widget.size + (widget.size * _animation.value * 0.8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: 0.3 * (1 - _animation.value)),
          ),
          child: Center(
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
                border: Border.all(color: Colors.black, width: 2),
              ),
            ),
          ),
        );
      },
    );
  }
}
