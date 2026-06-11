import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:nexlinks/features/calling/data/models/call_session_model.dart';
import 'package:nexlinks/features/calling/data/services/call_signaling_service.dart';
import 'package:nexlinks/features/calling/domain/repositories/call_repository.dart';
import 'package:nexlinks/features/calling/logic/call_lifecycle_event.dart';
import 'package:nexlinks/features/calling/logic/call_lifecycle_state.dart';

class CallLifecycleBloc extends Bloc<CallLifecycleEvent, CallLifecycleState> {
  final CallRepository _callRepository;
  final CallSignalingService _signalingService;
  final String _appId;
  final String _currentUserId;
  final String _currentUserName;
  final String _currentUserAvatarUrl;

  StreamSubscription<CallSession?>? _sessionSubscription;
  Timer? _timeoutTimer;

  CallLifecycleBloc({
    required CallRepository callRepository,
    required CallSignalingService signalingService,
    required String appId,
    required String currentUserId,
    required String currentUserName,
    required String currentUserAvatarUrl,
  })  : _callRepository = callRepository,
        _signalingService = signalingService,
        _appId = appId,
        _currentUserId = currentUserId,
        _currentUserName = currentUserName,
        _currentUserAvatarUrl = currentUserAvatarUrl,
        super(const CallIdleState()) {
    on<StartCallEvent>(_onStartCall);
    on<IncomingCallReceivedEvent>(_onIncomingCallReceived);
    on<AcceptCallEvent>(_onAcceptCall);
    on<DeclineCallEvent>(_onDeclineCall);
    on<RemoteAnsweredEvent>(_onRemoteAnswered);
    on<RemoteDeclinedEvent>(_onRemoteDeclined);
    on<EndCallEvent>(_onEndCall);
    on<CallTimeoutEvent>(_onCallTimeout);
    on<ToggleMicEvent>(_onToggleMic);
    on<ToggleCameraEvent>(_onToggleCamera);
    on<SwitchCameraEvent>(_onSwitchCamera);
    on<ResetBlocEvent>(_onResetBloc);
    on<RemoteUserJoinedEvent>(_onRemoteUserJoinedEvent);
    on<RemoteUserLeftEvent>(_onRemoteUserLeftEvent);
  }

  /// Dispatched when the caller initiates a call
  Future<void> _onStartCall(StartCallEvent event, Emitter<CallLifecycleState> emit) async {
    final channelId = 'call_${_currentUserId}_${event.receiverId}';

    emit(CallOutgoingRingingState(
      channelId: channelId,
      receiverId: event.receiverId,
      receiverName: event.receiverName,
      receiverAvatarUrl: event.receiverAvatarUrl,
      type: event.type,
    ));

    try {
      // 1. Create a Call Session in Firestore (creates ringing document and triggers FCM)
      await _signalingService.createCallSession(
        channelId: channelId,
        callerId: _currentUserId,
        callerName: _currentUserName,
        callerAvatarUrl: _currentUserAvatarUrl,
        receiverId: event.receiverId,
        type: event.type,
      );

      // 2. Start a 30-second timeout timer (ringing timeout)
      _startTimeoutTimer();

      // 3. Listen to the Call Session updates to see when B accepts/declines
      _sessionSubscription?.cancel();
      _sessionSubscription = _signalingService.listenToCallSession(channelId).listen((session) {
        if (session == null) return;

        if (session.status == CallStatus.accepted) {
          add(const RemoteAnsweredEvent());
        } else if (session.status == CallStatus.declined) {
          add(const RemoteDeclinedEvent());
        } else if (session.status == CallStatus.ended) {
          add(const EndCallEvent());
        }
      });
    } catch (e) {
      emit(CallEndedState('Error initiating call: ${e.toString()}'));
    }
  }

  /// Dispatched when receiver gets background/FCM call signaling
  void _onIncomingCallReceived(IncomingCallReceivedEvent event, Emitter<CallLifecycleState> emit) {
    emit(CallIncomingRingingState(event.session));

    _startTimeoutTimer();

    // Listen to call session status in case caller cancels call (status becomes 'ended' or 'declined')
    _sessionSubscription?.cancel();
    _sessionSubscription = _signalingService.listenToCallSession(event.session.id).listen((session) {
      if (session == null) return;

      if (session.status == CallStatus.ended || session.status == CallStatus.declined) {
        add(const EndCallEvent());
      }
    });
  }

  /// Dispatched when receiver clicks 'Accept'
  Future<void> _onAcceptCall(AcceptCallEvent event, Emitter<CallLifecycleState> emit) async {
    final currentState = state;
    if (currentState is! CallIncomingRingingState) return;

    _stopTimeoutTimer();
    final session = currentState.session;

    try {
      // 1. Update Firestore call session status to accepted
      await _signalingService.acceptCall(session.id);

      // 2. Request microphone and camera permissions
      final hasPermissions = await _requestPermissions(session.type == CallType.video);
      if (!hasPermissions) {
        emit(const CallEndedState('Permission Denied'));
        return;
      }

      // 3. Initialize Agora and Join Channel
      await _callRepository.initialize(appId: _appId);

      _callRepository.engine.registerEventHandler(
        RtcEngineEventHandler(
          onUserJoined: (connection, remoteUid, elapsed) {
            add(RemoteUserJoinedEvent(remoteUid));
          },
          onUserOffline: (connection, remoteUid, reason) {
            add(RemoteUserLeftEvent(remoteUid));
          },
        ),
      );

      await _callRepository.joinChannel(
        channelId: session.id,
        token: '', // using token-less / temp token mode
        uid: 0,
        enableVideo: session.type == CallType.video,
      );

      emit(CallActiveState(
        channelId: session.id,
        remoteUsername: session.callerName,
        remoteAvatarUrl: session.callerAvatarUrl,
        isVideoEnabled: session.type == CallType.video,
        isCameraMuted: session.type != CallType.video,
      ));
    } catch (e) {
      emit(CallEndedState('Failed to accept call: ${e.toString()}'));
    }
  }

  /// Dispatched when caller receives notice that the receiver accepted
  Future<void> _onRemoteAnswered(RemoteAnsweredEvent event, Emitter<CallLifecycleState> emit) async {
    final currentState = state;
    if (currentState is! CallOutgoingRingingState) return;

    _stopTimeoutTimer();

    try {
      // 1. Request microphone and camera permissions
      final hasPermissions = await _requestPermissions(currentState.type == CallType.video);
      if (!hasPermissions) {
        emit(const CallEndedState('Permission Denied'));
        return;
      }

      // 2. Initialize Agora and Join Channel
      await _callRepository.initialize(appId: _appId);

      _callRepository.engine.registerEventHandler(
        RtcEngineEventHandler(
          onUserJoined: (connection, remoteUid, elapsed) {
            add(RemoteUserJoinedEvent(remoteUid));
          },
          onUserOffline: (connection, remoteUid, reason) {
            add(RemoteUserLeftEvent(remoteUid));
          },
        ),
      );

      await _callRepository.joinChannel(
        channelId: currentState.channelId,
        token: '',
        uid: 0,
        enableVideo: currentState.type == CallType.video,
      );

      emit(CallActiveState(
        channelId: currentState.channelId,
        remoteUsername: currentState.receiverName,
        remoteAvatarUrl: currentState.receiverAvatarUrl,
        isVideoEnabled: currentState.type == CallType.video,
        isCameraMuted: currentState.type != CallType.video,
      ));
    } catch (e) {
      emit(CallEndedState('Failed to connect call: ${e.toString()}'));
    }
  }

  /// Dispatched when receiver declines call
  Future<void> _onDeclineCall(DeclineCallEvent event, Emitter<CallLifecycleState> emit) async {
    _stopTimeoutTimer();
    final currentState = state;
    if (currentState is CallIncomingRingingState) {
      await _signalingService.declineCall(currentState.session.id);
    }
    emit(const CallEndedState('declined'));
  }

  /// Dispatched when caller detects receiver declined call
  void _onRemoteDeclined(RemoteDeclinedEvent event, Emitter<CallLifecycleState> emit) {
    _stopTimeoutTimer();
    emit(const CallEndedState('declined'));
  }

  /// Dispatched when any participant hangs up
  Future<void> _onEndCall(EndCallEvent event, Emitter<CallLifecycleState> emit) async {
    _stopTimeoutTimer();
    final currentState = state;
    String? channelId;

    if (currentState is CallActiveState) {
      channelId = currentState.channelId;
    } else if (currentState is CallIncomingRingingState) {
      channelId = currentState.session.id;
    } else if (currentState is CallOutgoingRingingState) {
      channelId = currentState.channelId;
    }

    if (channelId != null) {
      await _signalingService.endCall(channelId);
    }

    try {
      await _callRepository.leaveChannel();
      await _callRepository.release();
    } catch (_) {}

    emit(const CallEndedState('ended'));
  }

  /// Dispatched when call ringing times out (no answer)
  Future<void> _onCallTimeout(CallTimeoutEvent event, Emitter<CallLifecycleState> emit) async {
    _stopTimeoutTimer();
    final currentState = state;

    if (currentState is CallIncomingRingingState) {
      await _signalingService.timeoutCall(currentState.session.id);
    } else if (currentState is CallOutgoingRingingState) {
      await _signalingService.timeoutCall(currentState.channelId);
    }

    try {
      await _callRepository.leaveChannel();
      await _callRepository.release();
    } catch (_) {}

    emit(const CallEndedState('no_answer'));
  }

  /// Toggles mic mute state
  Future<void> _onToggleMic(ToggleMicEvent event, Emitter<CallLifecycleState> emit) async {
    final currentState = state;
    if (currentState is CallActiveState) {
      final muted = !currentState.isMicMuted;
      await _callRepository.toggleMuteMicrophone(mute: muted);
      emit(currentState.copyWith(isMicMuted: muted));
    }
  }

  /// Toggles camera mute state
  Future<void> _onToggleCamera(ToggleCameraEvent event, Emitter<CallLifecycleState> emit) async {
    final currentState = state;
    if (currentState is CallActiveState && currentState.isVideoEnabled) {
      final muted = !currentState.isCameraMuted;
      await _callRepository.toggleMuteCamera(mute: muted);
      emit(currentState.copyWith(isCameraMuted: muted));
    }
  }

  /// Switches front/rear camera
  Future<void> _onSwitchCamera(SwitchCameraEvent event, Emitter<CallLifecycleState> emit) async {
    final currentState = state;
    if (currentState is CallActiveState && currentState.isVideoEnabled && !currentState.isCameraMuted) {
      await _callRepository.switchCamera();
    }
  }

  /// Resets bloc state
  void _onResetBloc(ResetBlocEvent event, Emitter<CallLifecycleState> emit) {
    _sessionSubscription?.cancel();
    _stopTimeoutTimer();
    emit(const CallIdleState());
  }

  void _onRemoteUserJoinedEvent(RemoteUserJoinedEvent event, Emitter<CallLifecycleState> emit) {
    final currentState = state;
    if (currentState is CallActiveState) {
      final updatedUids = List<int>.from(currentState.remoteUids);
      if (!updatedUids.contains(event.uid)) {
        updatedUids.add(event.uid);
      }
      emit(currentState.copyWith(remoteUids: updatedUids));
    }
  }

  void _onRemoteUserLeftEvent(RemoteUserLeftEvent event, Emitter<CallLifecycleState> emit) {
    final currentState = state;
    if (currentState is CallActiveState) {
      final updatedUids = List<int>.from(currentState.remoteUids)..remove(event.uid);
      if (updatedUids.isEmpty) {
        // If all remote users leave, end the call
        add(const EndCallEvent());
      } else {
        emit(currentState.copyWith(remoteUids: updatedUids));
      }
    }
  }

  void _startTimeoutTimer() {
    _stopTimeoutTimer();
    _timeoutTimer = Timer(const Duration(seconds: 30), () {
      add(const CallTimeoutEvent());
    });
  }

  void _stopTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
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
  Future<void> close() {
    _sessionSubscription?.cancel();
    _stopTimeoutTimer();
    return super.close();
  }
}
