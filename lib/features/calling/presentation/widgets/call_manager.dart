import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexlinks/features/auth/logic/auth_bloc.dart';
import 'package:nexlinks/features/auth/logic/auth_state.dart';
import 'package:nexlinks/features/calling/data/services/call_signaling_service.dart';
import 'package:nexlinks/features/calling/domain/repositories/call_repository.dart';
import 'package:nexlinks/features/calling/data/repositories/call_repository_impl.dart';
import 'package:nexlinks/features/calling/logic/call_lifecycle_bloc.dart';
import 'package:nexlinks/features/calling/logic/call_lifecycle_event.dart';
import 'package:nexlinks/features/calling/logic/call_lifecycle_state.dart';
import 'package:nexlinks/features/calling/presentation/screens/incoming_call_screen.dart';

import 'package:nexlinks/router/navigator_key.dart';

class CallManager extends StatefulWidget {
  final Widget child;

  const CallManager({super.key, required this.child});

  @override
  State<CallManager> createState() => _CallManagerState();
}

class _CallManagerState extends State<CallManager> {
  CallLifecycleBloc? _callLifecycleBloc;
  StreamSubscription? _incomingCallsSubscription;
  final CallSignalingService _signalingService = CallSignalingService();
  final CallRepository _callRepository = CallRepositoryImpl();

  @override
  void dispose() {
    _incomingCallsSubscription?.cancel();
    _callLifecycleBloc?.close();
    super.dispose();
  }

  void _setupCallBloc(String userId, String username, String avatarUrl) {
    if (_callLifecycleBloc != null) return;

    _callLifecycleBloc = CallLifecycleBloc(
      callRepository: _callRepository,
      signalingService: _signalingService,
      appId: '00ac1a5624af4c70b44aaa96ba3a706e', 
      currentUserId: userId,
      currentUserName: username,
      currentUserAvatarUrl: avatarUrl,
    );

    _incomingCallsSubscription = _signalingService.listenToIncomingCalls(userId).listen((sessions) {
      if (sessions.isNotEmpty && _callLifecycleBloc?.state is CallIdleState) {
        final session = sessions.first;
        _callLifecycleBloc!.add(IncomingCallReceivedEvent(session));

        rootNavigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => IncomingCallScreen(session: session),
          ),
        );
      }
    });
  }

  void _clearCallBloc() {
    _incomingCallsSubscription?.cancel();
    _incomingCallsSubscription = null;
    _callLifecycleBloc?.close();
    _callLifecycleBloc = null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated && state.user != null) {
          _setupCallBloc(
            state.user!.id,
            state.user!.username,
            state.user!.photoURL ?? '',
          );
        } else {
          _clearCallBloc();
        }
      },
      child: _callLifecycleBloc != null
          ? BlocProvider<CallLifecycleBloc>.value(
              value: _callLifecycleBloc!,
              child: widget.child,
            )
          : widget.child,
    );
  }
}
