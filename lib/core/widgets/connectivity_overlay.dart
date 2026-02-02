import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nexlinks/core/services/connectivity_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectivityOverlay extends StatefulWidget {
  final Widget child;

  const ConnectivityOverlay({super.key, required this.child});

  @override
  State<ConnectivityOverlay> createState() => _ConnectivityOverlayState();
}

class _ConnectivityOverlayState extends State<ConnectivityOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnimation;
  ConnectivityStatus _lastStatus = ConnectivityStatus.online;
  bool _showBanner = false;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _offsetAnimation = Tween<double>(begin: -100.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _dismissTimer?.cancel();
    super.dispose();
  }

  void _handleStatusChange(ConnectivityStatus status) {
    if (status == _lastStatus) return;

    if (status == ConnectivityStatus.offline) {
      setState(() {
        _showBanner = true;
      });
      _controller.forward();
    } else if (status == ConnectivityStatus.online && _lastStatus == ConnectivityStatus.offline) {
      // Briefly show "Back Online" then dismiss
      _controller.forward(); // Ensure it's visible
      _dismissTimer?.cancel();
      _dismissTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          _controller.reverse().then((_) {
            if (mounted) {
              setState(() {
                _showBanner = false;
              });
            }
          });
        }
      });
    }

    _lastStatus = status;
  }

  @override
  Widget build(BuildContext context) {
    final connectivityService = context.read<ConnectivityService>();

    return StreamBuilder<ConnectivityStatus>(
      stream: connectivityService.statusStream,
      builder: (context, snapshot) {
        final status = snapshot.data ?? ConnectivityStatus.online;
        
        // Use addPostFrameCallback to avoid calling setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleStatusChange(status);
        });

        return Stack(
          children: [
            widget.child,
            if (_showBanner)
              AnimatedBuilder(
                animation: _offsetAnimation,
                builder: (context, child) {
                  return Positioned(
                    top: _offsetAnimation.value + MediaQuery.of(context).padding.top,
                    left: 16,
                    right: 16,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: status == ConnectivityStatus.offline 
                            ? const Color(0xFFD32F2F).withValues(alpha: 0.9)
                            : const Color(0xFF388E3C).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              status == ConnectivityStatus.offline 
                                ? Icons.wifi_off_rounded 
                                : Icons.wifi_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    status == ConnectivityStatus.offline 
                                      ? "No Internet Connection" 
                                      : "Back Online",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (status == ConnectivityStatus.offline)
                                    Text(
                                      "Please check your network settings",
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
