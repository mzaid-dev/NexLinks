import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexlinks/features/auth/domain/repositories/auth_repository.dart';
import 'package:nexlinks/features/auth/data/models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:nexlinks/core/services/error_handler.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
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
    await _userSubscription?.cancel();
    _userSubscription = _authRepository.user.listen((user) {
      if (user != null && user is UserModel) {
        add(_AuthUserChanged(user));
      } else if (user != null) {
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
      await _authRepository.signInWithEmailAndPassword(
        event.email,
        event.password,
      );
    } catch (e) {
      emit(AuthState.failure(ErrorHandler.getMessage(e)));
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
        fullName: event.fullName,
      );
      if (user != null) {
        emit(AuthState.authenticated(user as UserModel));
      }
    } catch (e) {
      emit(AuthState.failure(ErrorHandler.getMessage(e)));
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
      emit(AuthState.failure(ErrorHandler.getMessage(e)));
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
      } else {
        emit(const AuthState.unauthenticated());
      }
    } catch (e) {
      emit(AuthState.failure(ErrorHandler.getMessage(e)));
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
      emit(AuthState.failure(ErrorHandler.getMessage(e)));
    }
  }
}

class _AuthUserChanged extends AuthEvent {
  final UserModel? user;
  const _AuthUserChanged(this.user);
  @override
  List<Object?> get props => [user];
}
