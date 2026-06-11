import 'package:agora_rtc_engine/agora_rtc_engine.dart';

abstract class CallRepository {

  RtcEngine get engine;

  Future<void> initialize({required String appId});

  Future<void> joinChannel({
    required String channelId,
    required String token,
    required int uid,
    required bool enableVideo,
  });

  Future<void> leaveChannel();

  Future<void> toggleMuteMicrophone({required bool mute});

  Future<void> toggleMuteCamera({required bool mute});

  Future<void> switchCamera();

  Future<void> release();
}
