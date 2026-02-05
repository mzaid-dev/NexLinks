import 'package:nexlinks/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:nexlinks/features/auth/domain/entities/auth_user.dart';
import 'package:nexlinks/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<AuthUser?> get user => remoteDataSource.user;

  @override
  Future<AuthUser?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await remoteDataSource.signInWithEmailAndPassword(email, password);
  }

  @override
  Future<AuthUser?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) async {
    return await remoteDataSource.registerWithEmailAndPassword(
      email: email,
      password: password,
      username: username,
      fullName: fullName,
    );
  }

  @override
  Future<void> signOut() async {
    return await remoteDataSource.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    return await remoteDataSource.sendPasswordResetEmail(email);
  }

  @override
  Future<void> deleteAccount() async {
    return await remoteDataSource.deleteAccount();
  }

  @override
  Future<bool> checkUsernameUnique(String username) async {
    return await remoteDataSource.checkUsernameUnique(username);
  }

  @override
  Future<AuthUser?> signInWithGoogle() async {
    return await remoteDataSource.signInWithGoogle();
  }

  @override
  Future<AuthUser?> signInWithFacebook() async {
    return await remoteDataSource.signInWithFacebook();
  }

  @override
  Future<AuthUser?> signInWithApple() async {
    return await remoteDataSource.signInWithApple();
  }
}
