import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:nexlinks/features/calling/data/models/call_session_model.dart';

class CallKitService {
  static Future<void> showIncomingCall(CallSession session) async {
    if (kIsWeb) return;

    final params = CallKitParams(
      id: session.id,
      nameCaller: session.callerName,
      appName: 'NexLinks',
      avatar: session.callerAvatarUrl.isNotEmpty ? session.callerAvatarUrl : 'https://i.pravatar.cc/150?img=33',
      handle: session.type == CallType.video ? 'Video Call' : 'Voice Call',
      type: session.type == CallType.video ? 1 : 0, // 0 = audio, 1 = video
      duration: 30000, // 30 seconds ringing timeout
      android: const AndroidParams(
        isHeaders: true,
        additionalFlags: [],
        incomingCallNotificationChannelName: 'Incoming Call',
        showLogo: true,
      ),
      ios: const IOSParams(
        iconName: 'AppIcon',
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 1,
        maximumCallsPerCallGroup: 1,
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  static void listenToCallKitEvents({
    required Function(String channelId) onAccept,
    required Function(String channelId) onDecline,
  }) {
    if (kIsWeb) return;

    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) {
      if (event == null) return;
      switch (event.event) {
        case Event.actionCallAccept:
          final String? channelId = event.body['id'] as String?;
          if (channelId != null) {
            onAccept(channelId);
          }
          break;
        case Event.actionCallDecline:
          final String? channelId = event.body['id'] as String?;
          if (channelId != null) {
            onDecline(channelId);
          }
          break;
        default:
          break;
      }
    });
  }

  static Future<void> endNativeCall(String channelId) async {
    if (kIsWeb) return;

    await FlutterCallkitIncoming.endCall(channelId);
  }
}
