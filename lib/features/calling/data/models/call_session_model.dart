import 'package:cloud_firestore/cloud_firestore.dart';

enum CallStatus { ringing, accepted, declined, ended, timeout }

enum CallType { voice, video }

class CallSession {
  final String id;
  final String callerId;
  final String callerName;
  final String callerAvatarUrl;
  final String receiverId;
  final CallStatus status;
  final CallType type;
  final DateTime createdAt;
  final DateTime? answeredAt;
  final DateTime? endedAt;

  CallSession({
    required this.id,
    required this.callerId,
    required this.callerName,
    required this.callerAvatarUrl,
    required this.receiverId,
    required this.status,
    required this.type,
    required this.createdAt,
    this.answeredAt,
    this.endedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'callerId': callerId,
      'callerName': callerName,
      'callerAvatarUrl': callerAvatarUrl,
      'receiverId': receiverId,
      'status': status.name,
      'type': type.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'answeredAt': answeredAt != null ? Timestamp.fromDate(answeredAt!) : null,
      'endedAt': endedAt != null ? Timestamp.fromDate(endedAt!) : null,
    };
  }

  factory CallSession.fromMap(Map<String, dynamic> map) {
    return CallSession(
      id: map['id'] ?? '',
      callerId: map['callerId'] ?? '',
      callerName: map['callerName'] ?? '',
      callerAvatarUrl: map['callerAvatarUrl'] ?? '',
      receiverId: map['receiverId'] ?? '',
      status: _parseStatus(map['status']),
      type: _parseType(map['type']),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      answeredAt: map['answeredAt'] != null
          ? (map['answeredAt'] as Timestamp).toDate()
          : null,
      endedAt: map['endedAt'] != null
          ? (map['endedAt'] as Timestamp).toDate()
          : null,
    );
  }

  static CallStatus _parseStatus(String? status) {
    if (status == null) return CallStatus.ringing;
    return CallStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => CallStatus.ringing,
    );
  }

  static CallType _parseType(String? type) {
    if (type == null) return CallType.voice;
    return CallType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => CallType.voice,
    );
  }

  CallSession copyWith({
    String? id,
    String? callerId,
    String? callerName,
    String? callerAvatarUrl,
    String? receiverId,
    CallStatus? status,
    CallType? type,
    DateTime? createdAt,
    DateTime? answeredAt,
    DateTime? endedAt,
  }) {
    return CallSession(
      id: id ?? this.id,
      callerId: callerId ?? this.callerId,
      callerName: callerName ?? this.callerName,
      callerAvatarUrl: callerAvatarUrl ?? this.callerAvatarUrl,
      receiverId: receiverId ?? this.receiverId,
      status: status ?? this.status,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      answeredAt: answeredAt ?? this.answeredAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }
}
