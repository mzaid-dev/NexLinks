import 'package:equatable/equatable.dart';

abstract class CallEvent extends Equatable {
  const CallEvent();

  @override
  List<Object?> get props => [];
}

class JoinCallEvent extends CallEvent {
  final String channelId;
  final String token;
  final int uid;
  final bool enableVideo;

  const JoinCallEvent({
    required this.channelId,
    this.token = '',
    this.uid = 0,
    this.enableVideo = true,
  });

  @override
  List<Object?> get props => [channelId, token, uid, enableVideo];
}

class LeaveCallEvent extends CallEvent {
  const LeaveCallEvent();
}

class ToggleMuteMicEvent extends CallEvent {
  const ToggleMuteMicEvent();
}

class ToggleMuteCameraEvent extends CallEvent {
  const ToggleMuteCameraEvent();
}

class SwitchCameraEvent extends CallEvent {
  const SwitchCameraEvent();
}

class RemoteUserJoinedEvent extends CallEvent {
  final int remoteUid;
  const RemoteUserJoinedEvent(this.remoteUid);

  @override
  List<Object?> get props => [remoteUid];
}

class RemoteUserLeftEvent extends CallEvent {
  final int remoteUid;
  const RemoteUserLeftEvent(this.remoteUid);

  @override
  List<Object?> get props => [remoteUid];
}
