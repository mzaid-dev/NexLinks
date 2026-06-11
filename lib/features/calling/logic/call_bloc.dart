import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:nexlinks/features/calling/domain/repositories/call_repository.dart';
import 'package:nexlinks/features/calling/logic/call_event.dart';
import 'package:nexlinks/features/calling/logic/call_state.dart';

class CallBloc extends Bloc<CallEvent, CallState> {
  final CallRepository _callRepository;
  final String _appId;

  CallBloc({
    required CallRepository callRepository,
    required String appId,
  })  : _callRepository = callRepository,
        _appId = appId,
        super(const CallInitial()) {
    on<JoinCallEvent>(_onJoinCall);
    on<LeaveCallEvent>(_onLeaveCall);
    on<ToggleMuteMicEvent>(_onToggleMuteMic);
    on<ToggleMuteCameraEvent>(_onToggleMuteCamera);
    on<SwitchCameraEvent>(_onSwitchCamera);
    on<RemoteUserJoinedEvent>(_onRemoteUserJoined);
    on<RemoteUserLeftEvent>(_onRemoteUserLeft);
  }

  Future<void> _onJoinCall(JoinCallEvent event, Emitter<CallState> emit) async {
    emit(const CallConnecting());

    try {
      // 1. Request required permissions
      final permissionsGranted = await _requestPermissions(event.enableVideo);
      if (!permissionsGranted) {
        emit(const CallError('Camera or Microphone permission was denied.'));
        return;
      }

      // 2. Initialize the Agora Engine
      await _callRepository.initialize(appId: _appId);

      // 3. Register Event Handlers to receive updates
      _callRepository.engine.registerEventHandler(
        RtcEngineEventHandler(
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            add(RemoteUserJoinedEvent(remoteUid));
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            add(RemoteUserLeftEvent(remoteUid));
          },
          onError: (ErrorCodeType err, String msg) {
            // Log or handle general RTC errors here if necessary
          },
        ),
      );

      // 4. Join the channel
      await _callRepository.joinChannel(
        channelId: event.channelId,
        token: event.token,
        uid: event.uid,
        enableVideo: event.enableVideo,
      );

      // Agora assigns a random local UID if we pass 0. Let's retrieve it or fallback to the requested uid.
      final localUid = event.uid == 0 ? 0 : event.uid;

      emit(CallActive(
        channelId: event.channelId,
        localUid: localUid,
        remoteUids: const [],
        isMicMuted: false,
        isCameraMuted: !event.enableVideo,
        isVideoEnabled: event.enableVideo,
      ));
    } catch (e) {
      emit(CallError('Failed to join call: ${e.toString()}'));
    }
  }

  Future<void> _onLeaveCall(LeaveCallEvent event, Emitter<CallState> emit) async {
    try {
      await _callRepository.leaveChannel();
      await _callRepository.release();
      emit(const CallDisconnected());
    } catch (e) {
      emit(CallError('Error leaving call: ${e.toString()}'));
    }
  }

  Future<void> _onToggleMuteMic(ToggleMuteMicEvent event, Emitter<CallState> emit) async {
    final currentState = state;
    if (currentState is CallActive) {
      final newMuteStatus = !currentState.isMicMuted;
      try {
        await _callRepository.toggleMuteMicrophone(mute: newMuteStatus);
        emit(currentState.copyWith(isMicMuted: newMuteStatus));
      } catch (e) {
        emit(CallError('Failed to toggle microphone: ${e.toString()}'));
      }
    }
  }

  Future<void> _onToggleMuteCamera(ToggleMuteCameraEvent event, Emitter<CallState> emit) async {
    final currentState = state;
    if (currentState is CallActive) {
      final newMuteStatus = !currentState.isCameraMuted;
      try {
        await _callRepository.toggleMuteCamera(mute: newMuteStatus);
        emit(currentState.copyWith(isCameraMuted: newMuteStatus));
      } catch (e) {
        emit(CallError('Failed to toggle camera: ${e.toString()}'));
      }
    }
  }

  Future<void> _onSwitchCamera(SwitchCameraEvent event, Emitter<CallState> emit) async {
    final currentState = state;
    if (currentState is CallActive && currentState.isVideoEnabled && !currentState.isCameraMuted) {
      try {
        await _callRepository.switchCamera();
      } catch (e) {
        emit(CallError('Failed to switch camera: ${e.toString()}'));
      }
    }
  }

  void _onRemoteUserJoined(RemoteUserJoinedEvent event, Emitter<CallState> emit) {
    final currentState = state;
    if (currentState is CallActive) {
      final updatedRemoteUids = List<int>.from(currentState.remoteUids);
      if (!updatedRemoteUids.contains(event.remoteUid)) {
        updatedRemoteUids.add(event.remoteUid);
      }
      emit(currentState.copyWith(remoteUids: updatedRemoteUids));
    }
  }

  void _onRemoteUserLeft(RemoteUserLeftEvent event, Emitter<CallState> emit) {
    final currentState = state;
    if (currentState is CallActive) {
      final updatedRemoteUids = List<int>.from(currentState.remoteUids)
        ..remove(event.remoteUid);
      emit(currentState.copyWith(remoteUids: updatedRemoteUids));
    }
  }

  Future<bool> _requestPermissions(bool includeVideo) async {
    final micStatus = await Permission.microphone.request();
    if (includeVideo) {
      final cameraStatus = await Permission.camera.request();
      return micStatus.isGranted && cameraStatus.isGranted;
    }
    return micStatus.isGranted;
  }

  @override
  Future<void> close() async {
    await _callRepository.release();
    return super.close();
  }
}
