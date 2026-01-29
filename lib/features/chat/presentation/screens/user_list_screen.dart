import 'package:chat_app/core/services/auth_service.dart';
import 'package:chat_app/core/services/firestoreservice.dart';
import 'package:chat_app/core/theme/app_theme.dart';
import 'package:chat_app/features/auth/data/model/user_model.dart';
import 'package:chat_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:chat_app/router/route_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:chat_app/features/auth/logic/auth_bloc.dart';
import 'package:chat_app/features/auth/logic/auth_event.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();
    final currentUserId = context.read<AuthService>().currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
             onPressed: () {
               context.read<AuthBloc>().add(AuthLogoutRequested());
            },
          )
        ],
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: firestoreService.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data ?? [];
          // Filter out current user
          final otherUsers = users.where((u) => u.id != currentUserId).toList();

          if (otherUsers.isEmpty) {
            return const Center(child: Text("No other users found."));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: otherUsers.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final user = otherUsers[index];
              return ListTile(
                leading: Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                      child: Text(
                        user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
                        style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (user.isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text(
                  user.username,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  user.isOnline ? "Online" : "Offline",
                  style: TextStyle(
                    color: user.isOnline ? Colors.green : Colors.grey,
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  context.push(AppRoutes.chat, extra: user);
                },
              );
            },
          );
        },
      ),
    );
  }
}
