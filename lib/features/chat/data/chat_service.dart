import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:nexlinks/features/chat/data/models/chat_message.dart';

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
    debugPrint("ChatService: Getting messages for $chatId. Current Auth User (Firebase): ${FirebaseAuth.instance.currentUser?.uid}");
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final status = doc.metadata.hasPendingWrites ? MessageStatus.pending : MessageStatus.sent;
        return ChatMessage.fromMap(doc.id, doc.data(), status: status);
      }).toList();
    });
  }



  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId, String currentUserId) async {
    // We want to mark messages sent by the OTHER person as read.
    // So we query messages where senderId != currentUserId and isRead == false
    // But Firestore doesn't support != in queries well for this without composite index or simple logic
    // A simpler way for this scale: Query all unread messages in this chat, 
    // and if senderId is NOT me, update them.
    
    // Better: Just query messages where isRead == false. Process client side or simple where.
    // Since we know the OTHER user id usually, we can say where('senderId', isEqualTo: otherUserId)
    // But getting the other user ID might be tricky inside this method unless passed.
    // For now, let's query all unread in this chat and filter.
    
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

  // Stream of unread count for a specific chat (sender)
  // This is effectively "Unread messages from User X" if chatId is the conversation with User X
  // AND we filter by messages NOT sent by me.
  Stream<int> getUnreadCountFromChatStream(String chatId, String currentUserId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
           return snapshot.docs.where((doc) => doc['senderId'] != currentUserId).length;
        }).distinct();
  }

  // Stream of TOTAL unread count for the current user across ALL chats
  // This is expensive with subcollections if we don't have a top-level aggregator.
  // Standard NoSQL pattern: We can't easily query "all messages in all subcollections".
  // OPTION 1: Maintain a 'unreadCounts' map in the User document. (Best for scale)
  // OPTION 2: Query 'chats' where 'participants' contains me, then combine streams? (Complex)
  // OPTION 3: Collection Group Query? 
  //   _firestore.collectionGroup('messages').where('isRead', isEqualTo: false).where('receiverId', isEqualTo: me)
  //   But our message schema doesn't strictly have 'receiverId' on every message, it has 'senderId'.
  //   We infer receiver by who else is in the chat.
  //   To make Collection Group work efficiently, we should add 'receiverId' to the message or 'participants'.
  //   Let's add 'receiverId' to sendMessage if possible, or just accept that for this prototype,
  //   we might have to do client side aggregation or simpler: 
  //   Show unread only PER CHAT in the list, and maybe don't show a global badge yet?
  //   OR: Let's try to update sendMessage to include `receiverId` (if data model allows, or infer it).
  //   Wait, `sendMessage` takes `chatId` and `senderId`. It doesn't know `receiverId` explicitly.
  //   
  //   Let's stick to PER CHAT unread indicators first (Red dot on user list).
  //   For the Global Badge (Bottom Nav), we might need to listen to the list of chats.
  //   
  //   Let's refine the plan:
  //   1. Update sendMessage: We can't easily add receiverId without fetching chat metadata.
  //   2. `getUnreadCountStream`: We will fetch all chats user is in, and listen to unread counts of each. 
  //      Flutter `rxdart` CombineLatest or similar would be good, but standard StreamBuilder nesting works too.
  //      Actually, let's keep it simple: The user asked for "show red dot on user list" and "bottom nav".
  //      If we can get the red dot on user list, we can sum them up?
  //      
  //   Let's try Collection Group Query by adding 'participants' array to the message? No.
  //   
  //   Revised Approach:
  //   Use `isRead` = false.
  //   For the User List: We already list users. We can listen to `getUnreadCountFromChatStream`.
  //   For the Global Badge: We can create a dedicated Stream that queries distinct unread messages?
  //   
  //   Actually, `sendMessage` knows `chatId`. 
  //   Let's just implement `getUnreadCountFromChatStream` correctly.
  //   And for global, we might cheat a bit or iterate.
  //   
  //   Wait, I can just use a Collection Group query on `messages` where `isRead` == false?
  //   But I need to filter by messages intended for ME.
  //   If I add `receiverId` to the message, it becomes trivial.
  //   I will add `receiverId` to `sendMessage` arguments. The specific screen calling it usually knows the receiver.
  
  // Revised sendMessage with receiverId and reactions initialization
  Future<void> sendMessage(String chatId, String text, String senderId, {String? receiverId}) async {
    if (text.trim().isEmpty) return;
    
    final data = {
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'reactions': {}, // Initialize empty reactions map
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

  // Toggle reaction on a message
  Future<void> toggleReaction(String chatId, String messageId, String userId, String emoji) async {
    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId);

    final doc = await messageRef.get();
    if (!doc.exists) return;

    final reactions = Map<String, String>.from(doc.data()?['reactions'] ?? {});
    
    if (reactions[userId] == emoji) {
      // Remove if same emoji
      reactions.remove(userId);
    } else {
      // Add or update to new emoji (WhatsApp style: one reaction per user)
      reactions[userId] = emoji;
    }

    await messageRef.update({'reactions': reactions});
  }

  // Global Unread Count Stream - Simplified approach without composite index
  // Listen to all chats user is part of, then count unread messages
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
            
            // Count messages NOT sent by me
            final unreadCount = unreadSnapshot.docs
                .where((doc) => doc['senderId'] != currentUserId)
                .length;
            
            totalUnread += unreadCount;
          }
          
          return totalUnread;
        })
        .distinct()
        .handleError((error) {
          debugPrint("ChatService Error: getGlobalUnreadCountStream failed. $error");
          return 0;
        });
  }
}
