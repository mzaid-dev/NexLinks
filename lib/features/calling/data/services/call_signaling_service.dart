import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexlinks/features/calling/data/models/call_session_model.dart';

class CallSignalingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _calls => _firestore.collection('call_sessions');

  // Creates the call session document in Firestore.
  // FCM notification is triggered automatically by the Cloud Function
  // (functions/index.js) that listens to onCreate on call_sessions.
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
}
