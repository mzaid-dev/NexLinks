import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:nexlinks/features/chat/data/models/chat_message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String getChatRoomId(String user1, String user2) {
    List<String> ids = [user1, user2];
    ids.sort();
    return ids.join("_");
  }

  Stream<List<ChatMessage>> getMessages(String chatId) {
    debugPrint(
      "ChatService: Getting messages for $chatId. Current Auth User (Firebase): ${FirebaseAuth.instance.currentUser?.uid}",
    );
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final status = doc.metadata.hasPendingWrites
                ? MessageStatus.pending
                : MessageStatus.sent;
            return ChatMessage.fromMap(doc.id, doc.data(), status: status);
          }).toList();
        });
  }

  Future<void> markMessagesAsRead(String chatId, String currentUserId) async {
    final unreadSnapshot = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in unreadSnapshot.docs) {
      if (doc['senderId'] != currentUserId) {
        batch.update(doc.reference, {'isRead': true});
      }
    }
    await batch.commit();
  }

  Stream<int> getUnreadCountFromChatStream(
    String chatId,
    String currentUserId,
  ) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .where((doc) => doc['senderId'] != currentUserId)
              .length;
        })
        .distinct();
  }

  Future<void> sendMessage(
    String chatId,
    String text,
    String senderId, {
    String? receiverId,
  }) async {
    if (text.trim().isEmpty) return;

    final data = {
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'reactions': {},
    };

    if (receiverId != null) {
      data['receiverId'] = receiverId;
    }

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(data);

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'participants': FieldValue.arrayUnion([senderId]),
    });
  }

  Future<void> toggleReaction(
    String chatId,
    String messageId,
    String userId,
    String emoji,
  ) async {
    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId);

    final doc = await messageRef.get();
    if (!doc.exists) return;

    final reactions = Map<String, String>.from(doc.data()?['reactions'] ?? {});

    if (reactions[userId] == emoji) {
      reactions.remove(userId);
    } else {
      reactions[userId] = emoji;
    }

    await messageRef.update({'reactions': reactions});
  }

  Stream<int> getGlobalUnreadCountStream(String currentUserId) {
    if (currentUserId.isEmpty) return Stream.value(0);

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .asyncMap((chatsSnapshot) async {
          int totalUnread = 0;

          for (var chatDoc in chatsSnapshot.docs) {
            final unreadSnapshot = await _firestore
                .collection('chats')
                .doc(chatDoc.id)
                .collection('messages')
                .where('isRead', isEqualTo: false)
                .get();

            final unreadCount = unreadSnapshot.docs
                .where((doc) => doc['senderId'] != currentUserId)
                .length;

            totalUnread += unreadCount;
          }

          return totalUnread;
        })
        .distinct()
        .handleError((error) {
          debugPrint(
            "ChatService Error: getGlobalUnreadCountStream failed. $error",
          );
          return 0;
        });
  }

  Stream<Map<String, dynamic>?> getLastMessageStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .snapshots()
        .map((doc) => doc.data());
  }
}
