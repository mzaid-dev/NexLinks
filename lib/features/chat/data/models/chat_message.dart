import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexlinks/core/utils/date_parser.dart';

enum MessageStatus { pending, sent, error }

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final Timestamp timestamp;
  final bool isRead;
  final MessageStatus status;

  final Map<String, String> reactions;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
    this.status = MessageStatus.sent,
    this.reactions = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp,
      'isRead': isRead,
      'reactions': reactions,
    };
  }

  static ChatMessage fromMap(String id, Map<String, dynamic> map, {MessageStatus? status}) {
    return ChatMessage(
      id: id,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: parseTimestamp(map['timestamp']),
      isRead: map['isRead'] ?? false,
      status: status ?? MessageStatus.sent,
      reactions: Map<String, String>.from(map['reactions'] ?? {}),
    );
  }

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? text,
    Timestamp? timestamp,
    bool? isRead,
    MessageStatus? status,
    Map<String, String>? reactions,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      status: status ?? this.status,
      reactions: reactions ?? this.reactions,
    );
  }
}
