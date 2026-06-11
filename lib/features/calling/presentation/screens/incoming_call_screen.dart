import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexlinks/core/theme/app_theme.dart';
import 'package:nexlinks/core/widgets/common/app_avatar.dart';
import 'package:nexlinks/core/widgets/common/glass_container.dart';
import 'package:nexlinks/core/widgets/common/tactile_feedback.dart';
import 'package:nexlinks/features/calling/data/models/call_session_model.dart';
import 'package:nexlinks/features/calling/logic/call_lifecycle_bloc.dart';
import 'package:nexlinks/features/calling/logic/call_lifecycle_event.dart';
import 'package:nexlinks/features/calling/logic/call_lifecycle_state.dart';
import 'package:nexlinks/features/calling/presentation/screens/call_screen.dart';

class IncomingCallScreen extends StatefulWidget {
  final CallSession session;

  const IncomingCallScreen({super.key, required this.session});

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _playRingtone();
  }

  Future<void> _playRingtone() async {
    try {

      await _audioPlayer.setReleaseMode(ReleaseMode.loop);

      await _audioPlayer.play(UrlSource(
        'https://assets.mixkit.co/active_storage/sfx/1359/1359-84.wav',
      ));

      if (mounted) {
        setState(() {
          _isPlaying = true;
        });
      }
    } catch (e) {
      debugPrint("IncomingCallScreen: Failed to play ringtone audio: $e");
    }
  }

  Future<void> _stopRingtone() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.dispose();
      _isPlaying = false;
    } catch (_) {}
  }

  @override
  void dispose() {
    _stopRingtone();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CallLifecycleBloc, CallLifecycleState>(
      listener: (context, state) {
        if (state is CallEndedState) {
          _stopRingtone();
          Navigator.of(context).pop();
        } else if (state is CallActiveState) {
          _stopRingtone();

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => CallScreen(
                channelId: state.channelId,
                enableVideo: state.isVideoEnabled,
                remoteUsername: state.remoteUsername,
                remoteAvatarUrl: state.remoteAvatarUrl,
              ),
            ),
          );
        }
      },
      child: Scaffold(
        body: Stack(
          children: [

            Container(
              decoration: BoxDecoration(
                image: widget.session.callerAvatarUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(widget.session.callerAvatarUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: Colors.black87,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.security_rounded,
                        color: Color(0xFF00FF94),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'NEXLINKS SECURE CALL',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  Hero(
                    tag: 'caller_avatar',
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00FF94).withValues(alpha: 0.2),
                            blurRadius: 30,
                            spreadRadius: 5,
                          )
                        ],
                      ),
                      child: AppAvatar(
                        imageUrl: widget.session.callerAvatarUrl,
                        customSize: 130,
                        initials: widget.session.callerName.isNotEmpty
                            ? widget.session.callerName[0]
                            : '?',
                        showBorder: true,
                        borderColor: const Color(0xFF00FF94),
                        borderWidth: 3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    widget.session.callerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Incoming ${widget.session.type == CallType.video ? "Video" : "Voice"} Call...',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 16,
                    ),
                  ),

                  const Spacer(flex: 2),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      borderRadius: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [

                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppTactileFeedback(
                                onTap: () {
                                  context.read<CallLifecycleBloc>().add(const DeclineCallEvent());
                                },
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.call_end_rounded,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Decline',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            ],
                          ),

                          const SizedBox(width: 40),

                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppTactileFeedback(
                                onTap: () {
                                  context.read<CallLifecycleBloc>().add(const AcceptCallEvent());
                                },
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF00FF94),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    widget.session.type == CallType.video
                                        ? Icons.videocam_rounded
                                        : Icons.call_rounded,
                                    color: Colors.black,
                                    size: 30,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Accept',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
