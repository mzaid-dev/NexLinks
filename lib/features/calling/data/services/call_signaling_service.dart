import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:nexlinks/features/calling/data/models/call_session_model.dart';

class CallSignalingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _calls => _firestore.collection('call_sessions');

  Future<CallSession> createCallSession({
    required String channelId,
    required String callerId,
    required String callerName,
    required String callerAvatarUrl,
    required String receiverId,
    required CallType type,
  }) async {
    final session = CallSession(
      id: channelId,
      callerId: callerId,
      callerName: callerName,
      callerAvatarUrl: callerAvatarUrl,
      receiverId: receiverId,
      status: CallStatus.ringing,
      type: type,
      createdAt: DateTime.now(),
    );

    await _calls.doc(channelId).set(session.toMap());

    await sendCallFcm(session);

    return session;
  }

  Stream<CallSession?> listenToCallSession(String channelId) {
    return _calls.doc(channelId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return CallSession.fromMap(snapshot.data() as Map<String, dynamic>);
    });
  }

  Stream<List<CallSession>> listenToIncomingCalls(String userId) {
    return _calls
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: CallStatus.ringing.name)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CallSession.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> acceptCall(String channelId) async {
    await _calls.doc(channelId).update({
      'status': CallStatus.accepted.name,
      'answeredAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> declineCall(String channelId) async {
    await _calls.doc(channelId).update({
      'status': CallStatus.declined.name,
      'endedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> endCall(String channelId) async {
    await _calls.doc(channelId).update({
      'status': CallStatus.ended.name,
      'endedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> timeoutCall(String channelId) async {
    await _calls.doc(channelId).update({
      'status': CallStatus.timeout.name,
      'endedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendCallFcm(CallSession session) async {
    try {

      final receiverDoc = await _firestore.collection('users').doc(session.receiverId).get();
      if (!receiverDoc.exists) return;

      final fcmToken = receiverDoc.data()?['fcmToken'] as String?;
      if (fcmToken == null || fcmToken.isEmpty) return;

      final payload = {
        'to': fcmToken,
        'priority': 'high',
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'type': 'call',
          'status': session.status.name,
          'channelId': session.id,
          'callerId': session.callerId,
          'callerName': session.callerName,
          'callerAvatarUrl': session.callerAvatarUrl,
          'callType': session.type.name,
        },
        'notification': {
          'title': 'Incoming ${session.type.name} call',
          'body': '${session.callerName} is calling you...',
          'sound': 'ringtone.mp3',
          'android_channel_id': 'calls_channel',
        }
      };

      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=YOUR_FCM_SERVER_KEY', 
        },
        body: jsonEncode(payload),
      );
    } catch (_) {

    }
  }
}
