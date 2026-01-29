import 'package:chat_app/features/auth/data/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class FirestoreService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser (UserModel user) async{
    try{
      await _firestore.collection('users').doc(user.id).set(user.toMap());
    }catch(e){
      throw Exception("Failed to Create User : ${e.toString()}");
    }
  }

  Future<UserModel?> getUser (String userId) async{
    try{
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if(doc.exists){
        return UserModel.fromMap(doc.data() as Map<String , dynamic>);
      }
      return null;
    }catch(e){
      throw Exception("Failed to Create User : ${e.toString()}");
    }
  }

  Future<void> updateUserOnlineStatus(String userId, bool isOnline) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isOnline': isOnline,
        'lastSeen': Timestamp.now(), // Use Timestamp instead of milliseconds
      });
    } catch (e) {
      throw Exception("Failed to Update User Online Status : ${e.toString()}");
    }
  }

  Future<void> deleteUser(String userId) async{
    try{
      await _firestore.collection('users').doc(userId).delete();
    }catch(e){
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
}