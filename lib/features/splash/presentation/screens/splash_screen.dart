import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:nexlinks/features/auth/logic/auth_bloc.dart';
import 'package:nexlinks/features/auth/logic/auth_state.dart';
import 'package:nexlinks/router/route_names.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashScreen>
    with TickerProviderStateMixin {
  String _phase = 'logo';
  double _progress = 0;
  late Timer _phaseTimer1;
  late Timer _phaseTimer2;
  late Timer _progressTimer;

  late AnimationController _scanlineController;

  bool _isAuthResolved = false;
  AuthStatus? _pendingStatus;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });

    _scanlineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _phaseTimer1 = Timer(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _phase = 'text');
    });

    _phaseTimer2 = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _phase = 'loading');
    });

    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;
      if (_phase == 'loading') {
        setState(() {
          if (_progress >= 100) {
            _progress = 100;
            timer.cancel();
            _checkAndExit();
          } else {
            if (_isAuthResolved) {
              _progress += 20;
            } else {
              _progress += math.Random().nextDouble() * 8;
            }
            if (_progress > 100) _progress = 100;
          }
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final currentState = context.read<AuthBloc>().state;
        if (currentState.status != AuthStatus.unknown) {
          setState(() {
            _isAuthResolved = true;
            _pendingStatus = currentState.status;
          });
        }
      }
    });
  }

  void _checkAndExit() {
    if (_progress >= 100 && _isAuthResolved) {
      setState(() => _phase = 'exit');

      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          _navigateNext();
        }
      });
    }
  }

  void _navigateNext() {
    if (_pendingStatus == AuthStatus.authenticated) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _phaseTimer1.cancel();
    _phaseTimer2.cancel();
    _progressTimer.cancel();
    _scanlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status != AuthStatus.unknown) {
          setState(() {
            _isAuthResolved = true;
            _pendingStatus = state.status;
          });

          if (_progress >= 100) {
            _checkAndExit();
          }
        }
      },
      child: Scaffold(backgroundColor: Colors.black, body: _buildBody()),
    );
  }

  Widget _buildBody() {
    final bool isExit = _phase == 'exit';

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 800),
      opacity: isExit ? 0.0 : 1.0,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 800),
        scale: isExit ? 1.1 : 1.0,
        curve: Curves.easeOutQuart,
        child: Stack(
          children: [
            Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2979FF).withValues(alpha: 0.12),
                      blurRadius: 100,
                      spreadRadius: 50,
                    ),
                  ],
                ),
              ),
            ),

            AnimatedBuilder(
              animation: _scanlineController,
              builder: (context, child) {
                return Positioned(
                  top:
                      MediaQuery.sizeOf(context).height *
                      _scanlineController.value,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          const Color(0xFF2979FF).withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 1000),
                    curve: const Cubic(0.2, 0.8, 0.2, 1.0),
                    width: 120,
                    height: 120,
                    transform: Matrix4.translationValues(
                      0,
                      _phase == 'logo' ? 40 : 0,
                      0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D0D0D),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2979FF).withValues(alpha: 0.2),
                          blurRadius: 50,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const _PulseGlow(),

                          Opacity(
                            opacity: _phase == 'logo' ? 0.0 : 1.0,
                            child: Image.asset(
                              'assets/branding/logo.png',
                              width: 70,
                              height: 70,
                              errorBuilder: (c, e, s) => const Icon(
                                Icons.hub_rounded,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  ClipRect(
                    child: AnimatedTitle(
                      visible:
                          _phase == 'text' ||
                          _phase == 'loading' ||
                          _phase == 'exit',
                      title: "NexLinks",
                      tagline: "CONNECT WITH FUTURE",
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 700),
                opacity: _phase == 'loading' || _phase == 'exit' ? 1.0 : 0.0,
                child: Center(
                  child: SizedBox(
                    width: 260,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "INITIALISING SYNC",
                              style: TextStyle(
                                color: Colors.white24,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              "${_progress.toInt()}%",
                              style: const TextStyle(
                                color: Color(0xFF2979FF),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 3,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _progress / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2979FF),
                                    Color(0xFF00F2FE),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF2979FF,
                                    ).withValues(alpha: 0.5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "NEURAL PROTOCOL V3.0.42",
                          style: TextStyle(
                            color: Colors.white10,
                            fontSize: 7,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulseGlow extends StatefulWidget {
  const _PulseGlow();

  @override
  State<_PulseGlow> createState() => _PulseGlowState();
}

class _PulseGlowState extends State<_PulseGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.1, end: 0.3).animate(_controller),
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF2979FF), Colors.transparent],
          ),
        ),
      ),
    );
  }
}

class AnimatedTitle extends StatelessWidget {
  final bool visible;
  final String title;
  final String tagline;

  const AnimatedTitle({
    super.key,
    required this.visible,
    required this.title,
    required this.tagline,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, visible ? 0 : 20, 0),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 700),
            opacity: visible ? 1.0 : 0.0,
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.white, Color(0xFFAAAAAA)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(bounds),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, visible ? 0 : 10, 0),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 700),
            opacity: visible ? 1.0 : 0.0,
            child: Text(
              tagline,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
