import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/features/chat/data/models/chat_message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Helper to generate chat room ID
  String getChatRoomId(String user1, String user2) {
    List<String> ids = [user1, user2];
    ids.sort();
    return ids.join("_");
  }

  // Stream messages ordered by timestamp for a specific chat
  Stream<List<ChatMessage>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ChatMessage.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Send a message
  Future<void> sendMessage(String chatId, String text, String senderId) async {
    if (text.trim().isEmpty) return;
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
