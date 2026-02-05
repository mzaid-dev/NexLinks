import 'package:nexlinks/features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateUser(UserModel user) async {
    try {
      if (user.id.trim().isEmpty) {
        throw ArgumentError("User ID is missing. Cannot perform update.");
      }
      await _firestore
          .collection('users')
          .doc(user.id)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception("Update failed: $e");
    }
  }

  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      throw Exception("Failed to Create User : ${e.toString()}");
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception("Failed to Get User: ${e.toString()}");
    }
  }

  Future<void> updateUserOnlineStatus(String userId, bool isOnline) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception("Failed to Update User Online Status : ${e.toString()}");
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception("Failed to Delete User : ${e.toString()}");
    }
  }

  Future<void> updateDisplayName(String displayName) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.reload();
      }
    } catch (e) {
      throw Exception("Failed to update display name: ${e.toString()}");
    }
  }

  Future<bool> checkUsernameUnique(String username) async {
    try {
      final result = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      return result.docs.isEmpty;
    } catch (e) {
      throw Exception("Failed to check username uniqueness: ${e.toString()}");
    }
  }

  Stream<List<UserModel>> getAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data());
      }).toList();
    });
  }

  Future<QuerySnapshot> getPaginatedUsers(
    int limit, {
    DocumentSnapshot? lastDocument,
  }) async {
    Query query = _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return await query.get();
  }

  Future<void> sendFriendRequest(
    String currentUserId,
    String viewedUserId,
  ) async {
    try {
      List<String> ids = [currentUserId, viewedUserId];
      ids.sort();
      String requestId = ids.join("_");

      final docRef = _firestore.collection('friend_requests').doc(requestId);
      final doc = await docRef.get();

      if (doc.exists) {
        final status = doc.get('status');

        if (status == 'pending' || status == 'accepted') return;
      }

      await docRef.set({
        'from': currentUserId,
        'to': viewedUserId,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Failed to send friend request: $e");
    }
  }

  Future<void> acceptFriendRequest(
    String requestId,
    String currentUserId,
    String viewedUserId,
  ) async {
    try {
      final batch = _firestore.batch();

      final requestRef = _firestore
          .collection('friend_requests')
          .doc(requestId);
      batch.update(requestRef, {'status': 'accepted'});

      final currentUserRef = _firestore.collection('users').doc(currentUserId);
      batch.update(currentUserRef, {
        'friends': FieldValue.arrayUnion([viewedUserId]),
      });

      final viewedUserRef = _firestore.collection('users').doc(viewedUserId);
      batch.update(viewedUserRef, {
        'friends': FieldValue.arrayUnion([currentUserId]),
      });

      List<String> ids = [currentUserId, viewedUserId];
      ids.sort();
      String chatId = ids.join("_");
      final chatRef = _firestore.collection('chats').doc(chatId);
      batch.set(chatRef, {
        'participants': ids,
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': null,
        'lastMessageTime': null,
      }, SetOptions(merge: true));

      await batch.commit();
    } catch (e) {
      throw Exception("Failed to accept friend request: $e");
    }
  }

  Stream<DocumentSnapshot> getFriendRequestStream(
    String currentUserId,
    String viewedUserId,
  ) {
    List<String> ids = [currentUserId, viewedUserId];
    ids.sort();
    String requestId = ids.join("_");
    return _firestore.collection('friend_requests').doc(requestId).snapshots();
  }

  Stream<QuerySnapshot> getIncomingRequestsStream(String userId) {
    return _firestore
        .collection('friend_requests')
        .where('to', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  Stream<QuerySnapshot> getSentRequestsStream(String userId) {
    return _firestore
        .collection('friend_requests')
        .where('from', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  Future<void> rejectFriendRequest(String requestId) async {
    try {
      await _firestore.collection('friend_requests').doc(requestId).update({
        'status': 'rejected',
      });
    } catch (e) {
      throw Exception("Failed to reject request: $e");
    }
  }

  Future<void> cancelFriendRequest(String requestId) async {
    try {
      await _firestore.collection('friend_requests').doc(requestId).delete();
    } catch (e) {
      throw Exception("Failed to cancel request: $e");
    }
  }

  Stream<UserModel> getUserStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) {
        return UserModel(
          id: userId,
          email: '',
          username: 'Unknown User',
          lastSeen: Timestamp.now(),
          createdAt: Timestamp.now(),
        );
      }
      return UserModel.fromMap(data);
    });
  }

  Stream<List<String>> getAvatars() {
    return _firestore.collection('avatars').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.get('url') as String).toList();
    });
  }
}
