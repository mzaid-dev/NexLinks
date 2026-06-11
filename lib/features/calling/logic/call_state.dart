import 'package:equatable/equatable.dart';

abstract class CallState extends Equatable {
  const CallState();

  @override
  List<Object?> get props => [];
}

class CallInitial extends CallState {
  const CallInitial();
}

class CallConnecting extends CallState {
  const CallConnecting();
}

class CallActive extends CallState {
  final String channelId;
  final int localUid;
  final List<int> remoteUids;
  final bool isMicMuted;
  final bool isCameraMuted;
  final bool isVideoEnabled;

  const CallActive({
    required this.channelId,
    required this.localUid,
    this.remoteUids = const [],
    this.isMicMuted = false,
    this.isCameraMuted = false,
    this.isVideoEnabled = true,
  });

  CallActive copyWith({
    String? channelId,
    int? localUid,
    List<int>? remoteUids,
    bool? isMicMuted,
    bool? isCameraMuted,
    bool? isVideoEnabled,
  }) {
    return CallActive(
      channelId: channelId ?? this.channelId,
      localUid: localUid ?? this.localUid,
      remoteUids: remoteUids ?? this.remoteUids,
      isMicMuted: isMicMuted ?? this.isMicMuted,
      isCameraMuted: isCameraMuted ?? this.isCameraMuted,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
    );
  }

  @override
  List<Object?> get props => [
        channelId,
        localUid,
        remoteUids,
        isMicMuted,
        isCameraMuted,
        isVideoEnabled,
      ];
}

class CallDisconnected extends CallState {
  const CallDisconnected();
}

class CallError extends CallState {
  final String message;

  const CallError(this.message);

  @override
  List<Object?> get props => [message];
}
