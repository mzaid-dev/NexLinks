import 'package:equatable/equatable.dart';
import 'package:nexlinks/features/calling/data/models/call_session_model.dart';

abstract class CallLifecycleEvent extends Equatable {
  const CallLifecycleEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched by the Caller to start a new call
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

/// Dispatched by FCM / Background signaling when an incoming call is received
class IncomingCallReceivedEvent extends CallLifecycleEvent {
  final CallSession session;

  const IncomingCallReceivedEvent(this.session);

  @override
  List<Object?> get props => [session];
}

/// Dispatched when receiver clicks 'Accept'
class AcceptCallEvent extends CallLifecycleEvent {
  const AcceptCallEvent();
}

/// Dispatched when receiver clicks 'Decline'
class DeclineCallEvent extends CallLifecycleEvent {
  const DeclineCallEvent();
}

/// Dispatched when caller detects receiver has accepted via Firestore subscription
class RemoteAnsweredEvent extends CallLifecycleEvent {
  const RemoteAnsweredEvent();
}

/// Dispatched when caller detects receiver has declined via Firestore subscription
class RemoteDeclinedEvent extends CallLifecycleEvent {
  const RemoteDeclinedEvent();
}

/// Dispatched when any participant hangs up
class EndCallEvent extends CallLifecycleEvent {
  const EndCallEvent();
}

/// Dispatched when ringing exceeds timeout duration
class CallTimeoutEvent extends CallLifecycleEvent {
  const CallTimeoutEvent();
}

/// Toggles microphone mute during active call
class ToggleMicEvent extends CallLifecycleEvent {
  const ToggleMicEvent();
}

/// Toggles camera active during active call
class ToggleCameraEvent extends CallLifecycleEvent {
  const ToggleCameraEvent();
}

/// Switches front/back camera during active video call
class SwitchCameraEvent extends CallLifecycleEvent {
  const SwitchCameraEvent();
}

/// Resets the BLoC back to idle state
class ResetBlocEvent extends CallLifecycleEvent {
  const ResetBlocEvent();
}
