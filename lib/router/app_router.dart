import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nexlinks/features/auth/logic/auth_bloc.dart';
import 'package:nexlinks/features/auth/logic/auth_state.dart';
import 'dart:async';


import 'package:nexlinks/features/home/presentation/screens/home_dashboard.dart';
import 'package:nexlinks/features/chat/presentation/screens/chat_screen.dart';
import 'package:nexlinks/features/splash/presentation/screens/splash_screen.dart';
import 'package:nexlinks/features/auth/data/models/user_model.dart';
import '../features/auth/presentation/screens/forgotpassword_view.dart';
import '../features/auth/presentation/screens/login_view.dart';
import 'package:nexlinks/features/profile/presentation/screens/profile_screen.dart';
import 'package:nexlinks/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:nexlinks/features/home/presentation/screens/network_screen.dart';

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
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.chat,
        pageBuilder: (context, state) {
          final user = state.extra as UserModel?;
          if (user == null) {
            // Redirect to home if user is null
            return CustomTransitionPage(
              key: state.pageKey,
              child: const HomeScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 300),
            );
          }
          return CustomTransitionPage(
            key: state.pageKey,
            child: ChatScreen(targetUser: user),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.05), // Subtle lift
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn)),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.network,
        builder: (context, state) => const NetworkScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        pageBuilder: (context, state) {
          final user = state.extra as UserModel?;
          return CustomTransitionPage(
            key: state.pageKey,
            child: ProfileScreen(
              user: user, 
              isMe: user == null || user.id == authBloc.state.user?.id
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.1), // Slide up from bottom
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn)),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) {
          final user = state.extra as UserModel?;
          if (user == null) {
            // Fallback to home if user is null
            return const HomeScreen();
          }
          return EditProfileScreen(user: user);
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
      }

      if (isAuth) {
        // If authenticated and on auth pages, go to home (Chat)
        if (isLoggingIn || isRegistering || isRecoveringPassword) {
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
