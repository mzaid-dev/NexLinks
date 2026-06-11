import 'package:equatable/equatable.dart';
import 'package:nexlinks/features/calling/data/models/call_session_model.dart';

abstract class CallLifecycleEvent extends Equatable {
  const CallLifecycleEvent();

  @override
  List<Object?> get props => [];
}

class StartCallEvent extends CallLifecycleEvent {
  final String receiverId;
  final String receiverName;
  final String receiverAvatarUrl;
  final CallType type;

  const StartCallEvent({
    required this.receiverId,
    required this.receiverName,
    required this.receiverAvatarUrl,
    required this.type,
  });

  @override
  List<Object?> get props => [receiverId, receiverName, receiverAvatarUrl, type];
}

class IncomingCallReceivedEvent extends CallLifecycleEvent {
  final CallSession session;

  const IncomingCallReceivedEvent(this.session);

  @override
  List<Object?> get props => [session];
}

class AcceptCallEvent extends CallLifecycleEvent {
  const AcceptCallEvent();
}

class DeclineCallEvent extends CallLifecycleEvent {
  const DeclineCallEvent();
}

class RemoteAnsweredEvent extends CallLifecycleEvent {
  const RemoteAnsweredEvent();
}

class RemoteDeclinedEvent extends CallLifecycleEvent {
  const RemoteDeclinedEvent();
}

class EndCallEvent extends CallLifecycleEvent {
  const EndCallEvent();
}

class CallTimeoutEvent extends CallLifecycleEvent {
  const CallTimeoutEvent();
}

class ToggleMicEvent extends CallLifecycleEvent {
  const ToggleMicEvent();
}

class ToggleCameraEvent extends CallLifecycleEvent {
  const ToggleCameraEvent();
}

class SwitchCameraEvent extends CallLifecycleEvent {
  const SwitchCameraEvent();
}

class ResetBlocEvent extends CallLifecycleEvent {
  const ResetBlocEvent();
}

class RemoteUserJoinedEvent extends CallLifecycleEvent {
  final int uid;
  const RemoteUserJoinedEvent(this.uid);

  @override
  List<Object?> get props => [uid];
}

class RemoteUserLeftEvent extends CallLifecycleEvent {
  final int uid;
  const RemoteUserLeftEvent(this.uid);

  @override
  List<Object?> get props => [uid];
}
