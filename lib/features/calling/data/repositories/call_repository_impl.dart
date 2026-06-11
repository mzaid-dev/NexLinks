import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:nexlinks/features/calling/domain/repositories/call_repository.dart';

class CallRepositoryImpl implements CallRepository {
  RtcEngine? _engine;

  @override
  RtcEngine get engine {
    if (_engine == null) {
      throw StateError('RtcEngine is not initialized. Call initialize() first.');
    }
    return _engine!;
  }

  @override
  Future<void> initialize({required String appId}) async {
    if (_engine != null) return;

    _engine = createAgoraRtcEngine();
    await _engine!.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );
  }

  @override
  Future<void> joinChannel({
    required String channelId,
    required String token,
    required int uid,
    required bool enableVideo,
  }) async {
    final rtcEngine = engine;

    if (enableVideo) {
      await rtcEngine.enableVideo();
      await rtcEngine.startPreview();
    } else {
      await rtcEngine.enableAudio();
    }

    // Set channel options and join
    await rtcEngine.joinChannel(
      token: token,
      channelId: channelId,
      uid: uid,
      options: ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
        publishCameraTrack: enableVideo,
        publishMicrophoneTrack: true,
      ),
    );
  }

  @override
  Future<void> leaveChannel() async {
    if (_engine != null) {
      await _engine!.leaveChannel();
    }
  }

  @override
  Future<void> toggleMuteMicrophone({required bool mute}) async {
    await engine.muteLocalAudioStream(mute);
  }

  @override
  Future<void> toggleMuteCamera({required bool mute}) async {
    await engine.muteLocalVideoStream(mute);
    if (mute) {
      await engine.stopPreview();
    } else {
      await engine.startPreview();
    }
  }

  @override
  Future<void> switchCamera() async {
    await engine.switchCamera();
  }

  @override
  Future<void> release() async {
    if (_engine != null) {
      try {
        await _engine!.leaveChannel();
      } catch (_) {}
      try {
        await _engine!.release();
      } catch (_) {}
      _engine = null;
    }
  }
}
