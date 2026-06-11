import 'package:equatable/equatable.dart';
import 'package:nexlinks/features/calling/data/models/call_session_model.dart';

abstract class CallLifecycleState extends Equatable {
  const CallLifecycleState();

  @override
  List<Object?> get props => [];
}

class CallIdleState extends CallLifecycleState {
  const CallIdleState();
}

class CallOutgoingRingingState extends CallLifecycleState {
  final String channelId;
  final String receiverId;
  final String receiverName;
  final String receiverAvatarUrl;
  final CallType type;

  const CallOutgoingRingingState({
    required this.channelId,
    required this.receiverId,
    required this.receiverName,
    required this.receiverAvatarUrl,
    required this.type,
  });

  @override
  List<Object?> get props => [channelId, receiverId, receiverName, receiverAvatarUrl, type];
}

class CallIncomingRingingState extends CallLifecycleState {
  final CallSession session;

  const CallIncomingRingingState(this.session);

  @override
  List<Object?> get props => [session];
}

class CallActiveState extends CallLifecycleState {
  final String channelId;
  final String remoteUsername;
  final String remoteAvatarUrl;
  final bool isVideoEnabled;
  final bool isMicMuted;
  final bool isCameraMuted;
  final List<int> remoteUids;
  final int localUid;

  const CallActiveState({
    required this.channelId,
    required this.remoteUsername,
    required this.remoteAvatarUrl,
    required this.isVideoEnabled,
    this.isMicMuted = false,
    this.isCameraMuted = false,
    this.remoteUids = const [],
    this.localUid = 0,
  });

  CallActiveState copyWith({
    String? channelId,
    String? remoteUsername,
    String? remoteAvatarUrl,
    bool? isVideoEnabled,
    bool? isMicMuted,
    bool? isCameraMuted,
    List<int>? remoteUids,
    int? localUid,
  }) {
    return CallActiveState(
      channelId: channelId ?? this.channelId,
      remoteUsername: remoteUsername ?? this.remoteUsername,
      remoteAvatarUrl: remoteAvatarUrl ?? this.remoteAvatarUrl,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
      isMicMuted: isMicMuted ?? this.isMicMuted,
      isCameraMuted: isCameraMuted ?? this.isCameraMuted,
      remoteUids: remoteUids ?? this.remoteUids,
      localUid: localUid ?? this.localUid,
    );
  }

  @override
  List<Object?> get props => [
        channelId,
        remoteUsername,
        remoteAvatarUrl,
        isVideoEnabled,
        isMicMuted,
        isCameraMuted,
        remoteUids,
        localUid,
      ];
}

class CallEndedState extends CallLifecycleState {
  final String reason;

  const CallEndedState(this.reason);

  @override
  List<Object?> get props => [reason];
}
