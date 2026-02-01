import 'package:nexlinks/features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthRemoteDataSource {
  Stream<UserModel?> get user;
  Future<UserModel?> signInWithEmailAndPassword(String email, String password);
  Future<UserModel?> registerWithEmailAndPassword({required String email, required String password, required String username});
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> deleteAccount();
  Future<bool> checkUsernameUnique(String username);
  Future<UserModel?> signInWithGoogle();
  Future<UserModel?> signInWithFacebook();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FlutterSecureStorage _storage;

  AuthRemoteDataSourceImpl({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FlutterSecureStorage? storage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? const FlutterSecureStorage();

  @override
  Stream<UserModel?> get user {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
       if (firebaseUser == null) return null;
       final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
       if (doc.exists) {
         return UserModel.fromMap(doc.data()!);
       }
       return null;
    });
  }

  @override
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      if (user != null) {
        await _storage.write(key: 'uid', value: user.uid);
        // Update online status
        await _firestore.collection('users').doc(user.uid).update({
          'isOnline': true,
          'lastSeen': FieldValue.serverTimestamp(),
        });
        
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception("Failed to Sign In: $e");
    }
  }

  @override
  Future<UserModel?> registerWithEmailAndPassword({required String email, required String password, required String username}) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      if (user != null) {
        await _storage.write(key: 'uid', value: user.uid);
        
        final userModel = UserModel(
          id: user.uid,
          email: email,
          username: username,
          lastSeen: Timestamp.now(), 
          role: 'user', // Explicitly set role
          isOnline: true,
          photoURL: '',
          createdAt: Timestamp.now(),
        );

        await _firestore.collection('users').doc(user.uid).set(userModel.toMap(), SetOptions(merge: true));
        return userModel;
      }
      return null;
    } catch (e) {
      throw Exception("Failed to Register: $e");
    }
  }

  @override
  Future<void> signOut() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
         await _firestore.collection('users').doc(user.uid).update({
          'isOnline': false,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }
      await _storage.delete(key: 'uid');
      await _auth.signOut();
    } catch (e) {
      throw Exception("Failed to Sign Out: $e");
    }
  }
  
  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception("Failed to Send Password Reset Email: $e");
    }
  }
  
  @override
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).delete();
        await _storage.delete(key: 'uid');
        await user.delete();
      }
    } catch (e) {
      throw Exception("Failed to Delete Account: $e");
    }
  }

  @override
  Future<bool> checkUsernameUnique(String username) async {
    try {
      final result = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      return result.docs.isEmpty;
    } catch (e) {
      throw Exception("Failed to check username uniqueness: $e");
    }
  }

  @override
  Future<UserModel?> signInWithGoogle() async {
    try {
      throw Exception("Google Sign-In configuration pending in Firebase Console.");
    } catch (e) {
      throw Exception("Google Sign-In Failed: $e");
    }
  }

  @override
  Future<UserModel?> signInWithFacebook() async {
    try {
      throw Exception("Facebook Sign-In configuration pending in Facebook Developer Portal.");
    } catch (e) {
      throw Exception("Facebook Sign-In Failed: $e");
    }
  }
}
