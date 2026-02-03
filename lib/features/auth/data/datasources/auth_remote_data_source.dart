import 'package:nexlinks/features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthRemoteDataSource {
  Stream<UserModel?> get user;
  Future<UserModel?> signInWithEmailAndPassword(String email, String password);
  Future<UserModel?> registerWithEmailAndPassword({required String email, required String password, required String username, required String fullName});
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
    UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
    User? user = result.user;
      if (user != null) {
        await _storage.write(key: 'uid', value: user.uid);
        // Update online status (Use set merge to handle missing docs gracefully)
        await _firestore.collection('users').doc(user.uid).set({
          'isOnline': true,
          'lastSeen': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) return UserModel.fromMap(doc.data()!);
      }
    return null;
  }

  @override
  Future<UserModel?> registerWithEmailAndPassword({required String email, required String password, required String username, required String fullName}) async {
    UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    User? user = result.user;
    if (user != null) {
      await _storage.write(key: 'uid', value: user.uid);
      
      final userModel = UserModel(
        id: user.uid,
        email: email,
        username: username,
        fullName: fullName,
        lastSeen: Timestamp.now(), 
        role: '', // Empty by default, user can set later
        isOnline: true,
        photoURL: '',
        createdAt: Timestamp.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(userModel.toMap(), SetOptions(merge: true));
      return userModel;
    }
    return null;
  }

  @override
  Future<void> signOut() async {
    final user = _auth.currentUser;
    if (user != null) {
       await _firestore.collection('users').doc(user.uid).set({
        'isOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    await _storage.delete(key: 'uid');
    await _auth.signOut();
  }
  
  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
  
  @override
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).delete();
      await _storage.delete(key: 'uid');
      await user.delete();
    }
  }

  @override
  Future<bool> checkUsernameUnique(String username) async {
    final result = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return result.docs.isEmpty;
  }

  @override
  Future<UserModel?> signInWithGoogle() async {
      final googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null; // Canceled by user

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result = await _auth.signInWithCredential(credential);
      final User? user = result.user;

      if (user != null) {
        await _storage.write(key: 'uid', value: user.uid);
        
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          // Create new user if first time
          
          // Get full name from Google profile
          final googleFullName = user.displayName ?? '';
          
          // Generate a unique username based on display name (or email prefix as fallback)
          String baseName = googleFullName;
          if (baseName.isEmpty && user.email != null) {
            baseName = user.email!.split('@').first;
          }
          final uniqueUsername = await _generateUniqueUsername(baseName.isNotEmpty ? baseName : 'user');

          final userModel = UserModel(
            id: user.uid,
            email: user.email ?? '',
            username: uniqueUsername,
            fullName: googleFullName.isNotEmpty ? googleFullName : null,
            lastSeen: Timestamp.now(),
            role: '', // Empty by default, user can set later
            isOnline: true,
            photoURL: user.photoURL ?? '',
            createdAt: Timestamp.now(),
          );
          await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
          return userModel;
        } else {
          // Update online status for existing user
          await _firestore.collection('users').doc(user.uid).set({
            'isOnline': true,
            'lastSeen': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          return UserModel.fromMap(doc.data()!);
        }
      }
      return null;
  }

  @override
  Future<UserModel?> signInWithFacebook() async {
    // throw Exception("Facebook Sign-In configuration pending in Facebook Developer Portal.");
    // Keeping this exception for now as it is logic-based, not platform-based
    throw UnimplementedError("Facebook login not configured yet.");
  }

  Future<String> _generateUniqueUsername(String displayName) async {
    // 1. Sanitize the display name to create a base username
    // Remove spaces, special characters, and convert to lowercase
    String baseName = displayName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (baseName.isEmpty) baseName = 'user';

    // 2. Check if the base name is already unique
    if (await checkUsernameUnique(baseName)) {
      return baseName;
    }

    // 3. If taken, try appending random numbers until unique
    int attempts = 0;
    while (attempts < 5) {
      // Generate a random 4-digit suffix
      final String suffix = (1000 + DateTime.now().microsecondsSinceEpoch % 9000).toString();
      final String candidate = '${baseName}_$suffix';

      if (await checkUsernameUnique(candidate)) {
        return candidate;
      }
      attempts++;
    }

    // 4. Fallback: Use timestamp to guarantee uniqueness if random retries fail
    return '${baseName}_${DateTime.now().millisecondsSinceEpoch}';
  }
}
