import 'package:chat_app/features/auth/domain/entities/auth_user.dart';

abstract class AuthRepository {
  Stream<AuthUser?> get user;
  
  Future<AuthUser?> signInWithEmailAndPassword(String email, String password);
  
  Future<AuthUser?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  });
  
  Future<void> signOut();
  
  Future<void> sendPasswordResetEmail(String email);
  
  Future<void> deleteAccount();
  
  Future<bool> checkUsernameUnique(String username);
}
