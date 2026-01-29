import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/core/services/auth_service.dart';
import 'package:chat_app/features/auth/data/model/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:chat_app/features/auth/logic/auth_error_handler.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  StreamSubscription<dynamic>? _userSubscription;

  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(const AuthState.unknown()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthDeleteAccountRequested>(_onAuthDeleteAccountRequested);
    on<_AuthUserChanged>(_onAuthUserChanged);
  }

  void _onAuthStarted(AuthStarted event, Emitter<AuthState> emit) async {
    // Add artificial delay to show Splash Screen
    await Future.delayed(const Duration(seconds: 2)); 
    
    await emit.onEach(_authService.authStateChanges, onData: (user) async {
       if (user != null) {
         try {
            final userModel = await _authService.getUserFromFirestore(user.uid);
            add(_AuthUserChanged(userModel));
         } catch (_) {
           add(const _AuthUserChanged(null));
         }
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
      await _authService.signInWithEmailAndPassword(event.email, event.password);
    } catch (e) {
      emit(AuthState.failure(AuthErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      await _authService.registerWithEmailAndPassword(
        event.email,
        event.password,
        event.username,
      );
    } catch (e) {
      emit(AuthState.failure(AuthErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authService.signOut();
  }
  
  Future<void> _onAuthDeleteAccountRequested(
    AuthDeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
      emit(const AuthState.loading());
      try {
        await _authService.deleteAccount();
      } catch (e) {
         emit(AuthState.failure(AuthErrorHandler.getErrorMessage(e)));
      }
  }
}

class _AuthUserChanged extends AuthEvent {
  final UserModel? user;
  const _AuthUserChanged(this.user);
  @override
  List<Object?> get props => [user];
}
