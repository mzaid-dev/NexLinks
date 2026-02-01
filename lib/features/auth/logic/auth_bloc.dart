import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexlinks/features/auth/domain/repositories/auth_repository.dart'; // Import Repo
import 'package:nexlinks/features/auth/data/models/user_model.dart'; // Keep for casting if needed, or better, use AuthUser
import 'auth_event.dart';
import 'auth_state.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository; // Use Repository
  StreamSubscription<dynamic>? _userSubscription;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState.unknown()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthDeleteAccountRequested>(_onAuthDeleteAccountRequested);
    on<AuthGoogleLoginRequested>(_onAuthGoogleLoginRequested);
    on<AuthFacebookLoginRequested>(_onAuthFacebookLoginRequested);
    on<_AuthUserChanged>(_onAuthUserChanged);
  }

  void _onAuthStarted(AuthStarted event, Emitter<AuthState> emit) async {
    // We can rely on the stream from the repo which typically handles persistence internally or via the datasource
    // But for now, let's just listen to the stream.
    
    await _userSubscription?.cancel();
    _userSubscription = _authRepository.user.listen((user) {
       // user is AuthUser?
        if (user != null && user is UserModel) {
            add(_AuthUserChanged(user));
        } else if (user != null) {
             // If it's not a UserModel (e.g. just AuthUser), we might need to cast or convert if the state expects UserModel
             // For now, let's assume the Repo returns the correct subtype or we verify State compatibility.
             // Our State likely expects UserModel. 
             // Ideally Domain shouldn't know about Data Model, so State should use AuthUser.
             // But let's assume for this refactor we pass it through.
             // Actually, the Repo returns AuthUser via signature, but runtime is UserModel.
             add(_AuthUserChanged(user as UserModel)); 
        } else {
            add(const _AuthUserChanged(null));
        }
    });
  }

  void _onAuthUserChanged(_AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(AuthState.authenticated(event.user!));
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.signInWithEmailAndPassword(event.email, event.password);
    } catch (e) {
      emit(AuthState.failure(e.toString()));
    }
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      final user = await _authRepository.registerWithEmailAndPassword(
        email: event.email,
        password: event.password,
        username: event.username,
      );
      if (user != null) {
        emit(AuthState.authenticated(user as UserModel));
      }
    } catch (e) {
      emit(AuthState.failure(e.toString()));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
  }
  
  Future<void> _onAuthDeleteAccountRequested(
    AuthDeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
      emit(const AuthState.loading());
      try {
        await _authRepository.deleteAccount();
      } catch (e) {
         emit(AuthState.failure(e.toString()));
      }
  }

  Future<void> _onAuthGoogleLoginRequested(
    AuthGoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      final user = await _authRepository.signInWithGoogle();
      if (user != null) {
        emit(AuthState.authenticated(user as UserModel));
      }
    } catch (e) {
      emit(AuthState.failure(e.toString()));
    }
  }

  Future<void> _onAuthFacebookLoginRequested(
    AuthFacebookLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      final user = await _authRepository.signInWithFacebook();
      if (user != null) {
        emit(AuthState.authenticated(user as UserModel));
      }
    } catch (e) {
      emit(AuthState.failure(e.toString()));
    }
  }
}

class _AuthUserChanged extends AuthEvent {
  final UserModel? user;
  const _AuthUserChanged(this.user);
  @override
  List<Object?> get props => [user];
}
