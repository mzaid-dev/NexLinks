import 'package:agora_rtc_engine/agora_rtc_engine.dart';

abstract class CallRepository {
  /// Exposes the RTC Engine instance to allow rendering [AgoraVideoView] in the presentation layer.
  RtcEngine get engine;

  /// Initializes the Agora RTC engine with the provided [appId].
  Future<void> initialize({required String appId});

  /// Joins an Agora RTC channel with the specified [channelId], [token], and [uid].
  /// [enableVideo] controls whether the video module is initially enabled/started.
  Future<void> joinChannel({
    required String channelId,
    required String token,
    required int uid,
    required bool enableVideo,
  });

  /// Leaves the current active Agora channel.
  Future<void> leaveChannel();

  /// Mutes or unmutes the local microphone.
  Future<void> toggleMuteMicrophone({required bool mute});

  /// Mutes or unmutes the local camera feed.
  Future<void> toggleMuteCamera({required bool mute});

  /// Switches between the front and rear cameras.
  Future<void> switchCamera();

  /// Releases and cleans up all resources used by the RTC Engine.
  Future<void> release();
}
