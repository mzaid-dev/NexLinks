import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/core/theme/app_theme.dart';
import 'package:chat_app/core/widgets/common/glass_container.dart';
import 'package:chat_app/core/widgets/common/app_avatar.dart';
import 'package:chat_app/core/widgets/common/tactile_feedback.dart';
import 'package:chat_app/core/widgets/common/mysnakebar.dart';
import 'package:chat_app/features/calling/domain/repositories/call_repository.dart';
import 'package:chat_app/features/calling/data/repositories/call_repository_impl.dart';
import 'package:chat_app/features/calling/logic/call_bloc.dart';
import 'package:chat_app/features/calling/logic/call_event.dart';
import 'package:chat_app/features/calling/logic/call_state.dart';

// Placeholder App ID. Replace with your actual Agora App ID in production.
const String _agoraAppId = '00ac1a5624af4c70b44aaa96ba3a706e';

class CallScreen extends StatelessWidget {
  final String channelId;
  final String token;
  final int uid;
  final bool enableVideo;
  final String remoteUsername;
  final String? remoteAvatarUrl;

  const CallScreen({
    super.key,
    required this.channelId,
    this.token = '',
    this.uid = 0,
    this.enableVideo = true,
    this.remoteUsername = 'Participant',
    this.remoteAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<CallRepository>(
      create: (context) => CallRepositoryImpl(),
      child: BlocProvider<CallBloc>(
        create: (context) => CallBloc(
          callRepository: context.read<CallRepository>(),
          appId: _agoraAppId,
        )..add(JoinCallEvent(
            channelId: channelId,
            token: token,
            uid: uid,
            enableVideo: enableVideo,
          )),
        child: CallView(
          remoteUsername: remoteUsername,
          remoteAvatarUrl: remoteAvatarUrl,
        ),
      ),
    );
  }
}

class CallView extends StatefulWidget {
  final String remoteUsername;
  final String? remoteAvatarUrl;

  const CallView({
    super.key,
    required this.remoteUsername,
    this.remoteAvatarUrl,
  });

  @override
  State<CallView> createState() => _CallViewState();
}

class _CallViewState extends State<CallView> with SingleTickerProviderStateMixin {
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _showControls = true;
  Timer? _controlsTimer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _resetControlsTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controlsTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_timer != null) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  void _resetControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControlsVisibility() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _resetControlsTimer();
    }
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CallBloc, CallState>(
      listener: (context, state) {
        if (state is CallActive) {
          _startTimer();
        } else if (state is CallDisconnected) {
          _timer?.cancel();
          MySnackBar.show(
            context: context,
            message: 'Call ended successfully',
            icon: Icons.call_end_rounded,
            backgroundColor: AppTheme.primaryColor,
          );
          Navigator.of(context).pop();
        } else if (state is CallError) {
          MySnackBar.show(
            context: context,
            message: state.message,
            isError: true,
          );
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.darkBgColor,
        body: BlocBuilder<CallBloc, CallState>(
          builder: (context, state) {
            if (state is CallInitial || state is CallConnecting) {
              return _buildConnectingState();
            } else if (state is CallActive) {
              _startTimer(); // Ensure timer starts if state is loaded directly
              return _buildActiveState(state);
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }

  Widget _buildConnectingState() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Dark premium background with a subtle ambient color
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.15),
                  AppTheme.darkBgColor,
                ],
                center: Alignment.center,
                radius: 1.2,
              ),
            ),
          ),
        ),
        SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 40),
              // Avatar & Pulsing Effect
              Column(
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryColor.withValues(
                            alpha: 0.08 * (1 - _pulseController.value),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.secondaryColor.withValues(
                              alpha: 0.12 * (1 - _pulseController.value),
                            ),
                          ),
                          child: child,
                        ),
                      );
                    },
                    child: AppAvatar(
                      imageUrl: widget.remoteAvatarUrl,
                      size: AppAvatarSize.xlarge,
                      initials: widget.remoteUsername.isNotEmpty
                          ? widget.remoteUsername.substring(0, 1)
                          : 'P',
                      showBorder: true,
                      borderColor: AppTheme.secondaryColor,
                      borderWidth: 2,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    widget.remoteUsername,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Connecting...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                              letterSpacing: 0.5,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              // End Call/Cancel Button
              Padding(
                padding: const EdgeInsets.only(bottom: 48.0),
                child: TactileFeedback(
                  onTap: () {
                    context.read<CallBloc>().add(const LeaveCallEvent());
                  },
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppTheme.errorColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.call_end_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveState(CallActive state) {
    return GestureDetector(
      onTap: _toggleControlsVisibility,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Video / Audio View
          Positioned.fill(
            child: _buildMainVideoOrPlaceholder(state),
          ),

          // 2. Picture-in-Picture Local Video View (Video call, remote user joined)
          if (state.isVideoEnabled && state.remoteUids.isNotEmpty)
            Positioned(
              top: 50,
              right: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 120,
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white12,
                      width: 1,
                    ),
                  ),
                  child: state.isCameraMuted
                      ? const Center(
                          child: Icon(
                            Icons.videocam_off_rounded,
                            color: Colors.white54,
                            size: 28,
                          ),
                        )
                      : AgoraVideoView(
                          controller: VideoViewController(
                            rtcEngine: context.read<CallRepository>().engine,
                            canvas: const VideoCanvas(uid: 0),
                          ),
                        ),
                ),
              ),
            ),

          // 3. Top Call Bar Overlay
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: _showControls ? 50 : -80,
            left: 20,
            right: 20,
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              borderRadius: BorderRadius.circular(20),
              child: Row(
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    color: AppTheme.secondaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.remoteUsername,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          state.isVideoEnabled ? 'Video Call' : 'Voice Call',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _formatDuration(_secondsElapsed),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Bottom Glassmorphic Control Bar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _showControls ? 40 : -100,
            left: 20,
            right: 20,
            child: _buildBottomControlBar(state),
          ),
        ],
      ),
    );
  }

  Widget _buildMainVideoOrPlaceholder(CallActive state) {
    if (state.isVideoEnabled) {
      if (state.remoteUids.isEmpty) {
        // Only local user in call, show full screen local preview
        return state.isCameraMuted
            ? _buildVoiceOnlyPlaceholder(state)
            : AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: context.read<CallRepository>().engine,
                  canvas: const VideoCanvas(uid: 0),
                ),
              );
      } else {
        // Remote user has joined, show remote video full screen
        final remoteUid = state.remoteUids.first;
        return AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: context.read<CallRepository>().engine,
            canvas: VideoCanvas(uid: remoteUid),
            connection: RtcConnection(channelId: state.channelId),
          ),
        );
      }
    } else {
      // Voice call layout
      return _buildVoiceOnlyPlaceholder(state);
    }
  }

  Widget _buildVoiceOnlyPlaceholder(CallActive state) {
    return Container(
      color: AppTheme.darkBgColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Ambient back-glow
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.15),
                    AppTheme.darkBgColor,
                  ],
                  center: Alignment.center,
                  radius: 1.2,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pulsing ring around avatar
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryColor.withValues(
                          alpha: 0.05 * (1 - _pulseController.value),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.secondaryColor.withValues(
                            alpha: 0.08 * (1 - _pulseController.value),
                          ),
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: AppAvatar(
                    imageUrl: widget.remoteAvatarUrl,
                    size: AppAvatarSize.xlarge,
                    initials: widget.remoteUsername.isNotEmpty
                        ? widget.remoteUsername.substring(0, 1)
                        : 'P',
                    showBorder: true,
                    borderColor: AppTheme.secondaryColor,
                    borderWidth: 2.5,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.remoteUsername,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.isMicMuted ? 'Muted' : 'Speaking...',
                  style: TextStyle(
                    color: state.isMicMuted
                        ? AppTheme.errorColor
                        : AppTheme.secondaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControlBar(CallActive state) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      borderRadius: BorderRadius.circular(30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 1. Mute Mic Button
          _buildControlButton(
            icon: state.isMicMuted
                ? Icons.mic_off_rounded
                : Icons.mic_rounded,
            color: state.isMicMuted ? AppTheme.errorColor : Colors.white24,
            iconColor: Colors.white,
            onPressed: () {
              context.read<CallBloc>().add(const ToggleMuteMicEvent());
              _resetControlsTimer();
            },
          ),

          // 2. Camera Toggle Button (Only show if video call)
          if (state.isVideoEnabled)
            _buildControlButton(
              icon: state.isCameraMuted
                  ? Icons.videocam_off_rounded
                  : Icons.videocam_rounded,
              color: state.isCameraMuted ? AppTheme.errorColor : Colors.white24,
              iconColor: Colors.white,
              onPressed: () {
                context.read<CallBloc>().add(const ToggleMuteCameraEvent());
                _resetControlsTimer();
              },
            ),

          // 3. Switch Camera Button (Only show if video call and camera is active)
          if (state.isVideoEnabled)
            _buildControlButton(
              icon: Icons.flip_camera_ios_rounded,
              color: state.isCameraMuted ? Colors.white10 : Colors.white24,
              iconColor: state.isCameraMuted ? Colors.white30 : Colors.white,
              onPressed: state.isCameraMuted
                  ? null
                  : () {
                      context.read<CallBloc>().add(const SwitchCameraEvent());
                      _resetControlsTimer();
                    },
            ),

          // 4. End Call Button (Red, prominent)
          _buildControlButton(
            icon: Icons.call_end_rounded,
            color: AppTheme.errorColor,
            iconColor: Colors.white,
            size: 58,
            iconSize: 28,
            onPressed: () {
              context.read<CallBloc>().add(const LeaveCallEvent());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback? onPressed,
    double size = 50,
    double iconSize = 22,
  }) {
    return TactileFeedback(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            icon,
            color: iconColor,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}
