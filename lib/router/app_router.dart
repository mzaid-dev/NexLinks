import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chat_app/features/auth/logic/auth_bloc.dart';
import 'package:chat_app/features/auth/logic/auth_state.dart';
import 'dart:async';

import 'package:chat_app/features/chat/presentation/screens/user_list_screen.dart';
import 'package:chat_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:chat_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:chat_app/features/auth/data/model/user_model.dart';
import '../features/auth/presentation/screens/forgotpassword_view.dart';
import '../features/auth/presentation/screens/login_view.dart';

import '../features/auth/presentation/screens/register_screen.dart';
import 'route_names.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) =>  SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterView(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPassword(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const UserListScreen(),
      ),
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) {
          final user = state.extra as UserModel;
          return ChatScreen(targetUser: user);
        },
      ),

    ],
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuth = authState.status == AuthStatus.authenticated;
      final isUnAuth = authState.status == AuthStatus.unauthenticated;
      
      final isSplash = state.matchedLocation == AppRoutes.splash;
      final isLoggingIn = state.matchedLocation == AppRoutes.login;
      final isRegistering = state.matchedLocation == AppRoutes.register;
      final isRecoveringPassword = state.matchedLocation == AppRoutes.forgotPassword;

      if (authState.status == AuthStatus.unknown) return null; // Let splash handle or wait

      if (isUnAuth) {
          // If unauthenticated and on a protected route, go to login
          // Allowed routes for unauthenticated users: login, register, forgot-password, splash
          if (!isLoggingIn && !isRegistering && !isRecoveringPassword && !isSplash) {
             return AppRoutes.login;
          }
          // If on splash and unauthenticated, go to login
          if(isSplash){
            return AppRoutes.login;
          }
      }

      if (isAuth) {
        // If authenticated and on auth pages, go to home (Chat)
        if (isLoggingIn || isRegistering || isRecoveringPassword || isSplash) {
          return AppRoutes.home;
        }
      }

      return null;
    },
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
