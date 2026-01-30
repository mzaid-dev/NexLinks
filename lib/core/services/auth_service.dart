import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestoreservice.dart' show FirestoreService;


import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final _storage = const FlutterSecureStorage();

  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        await _storage.write(key: 'uid', value: user.uid); // Store UID
        await _firestoreService.updateUserOnlineStatus(user.uid, true);
        return await _firestoreService.getUser(user.uid);
      }
      return null;
    } catch (e) {
      throw Exception("Failed to Sign In ${e.toString()}");
    }
  }

  Future<UserModel?> registerWithEmailAndPassword(
      String email,
      String password,
      String username,
      ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        await _storage.write(key: 'uid', value: user.uid); // Store UID
        await _firestoreService.updateDisplayName(username); 

        final userModel = UserModel(
          id: user.uid,
          email: email,
          username: username,
          lastSeen: Timestamp.now(), 
          isOnline: true,
          photoURL: '',
          createdAt: Timestamp.now(),
        );

        await _firestoreService.createUser(userModel);
        return userModel;
      }
      return null;
    } catch (e) {
      throw Exception("Failed to Register ${e.toString()}");
    }
  }

  Future<bool> checkUsernameUnique(String username) async {
    return await _firestoreService.checkUsernameUnique(username);
  }

  Future<void> sendPasswordResetEmail(String email) async{
    try{
      await _auth.sendPasswordResetEmail(email: email);
    }catch(e){
      throw Exception("Failed to Send Password Reset Email ${e.toString()}");
    }
  }

  Future<void> signOut() async{
    try{
      if(currentUser != null){
        await _firestoreService.updateUserOnlineStatus(currentUserId!,false);
      }
      await _storage.delete(key: 'uid'); // Delete UID
      _auth.signOut();
    }catch(e){
      throw Exception("Failed to Sign Out ${e.toString()}");
    }
  }

  Future<void> deleteAccount() async{
    try{
      User? user = _auth.currentUser;
      if(user != null){
        await _firestoreService.deleteUser(user.uid);
        await _storage.delete(key: 'uid'); // Delete UID
        await user.delete();
      }
    }catch(e){
      throw Exception("Failed to Delete Account ${e.toString()}");
    }
  }

  Future<UserModel?> getUserFromFirestore(String uid) async {
    return await _firestoreService.getUser(uid);
  }

  Future<String?> getPersistedUid() async {
    return await _storage.read(key: 'uid');
  }
}



