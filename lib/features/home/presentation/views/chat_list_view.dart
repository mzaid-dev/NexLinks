import 'package:chat_app/core/services/auth_service.dart';
import 'package:chat_app/core/services/firestoreservice.dart';
import 'package:chat_app/core/widgets/common/app_avatar.dart';
import 'package:chat_app/features/home/presentation/widgets/glass_card.dart';
import 'package:chat_app/router/route_names.dart';
import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:chat_app/features/chat/data/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:chat_app/core/widgets/common/app_base_view.dart';
import 'package:chat_app/core/widgets/common/app_loading_indicator.dart';
import 'package:animate_do/animate_do.dart';
import 'package:animated_text_kit/animated_text_kit.dart';


class ChatListView extends StatelessWidget {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();
    final currentUserId = context.read<AuthService>().currentUserId;
    if (currentUserId == null) return const SizedBox.shrink();

    final screenHeight = MediaQuery.of(context).size.height;

    return AppBaseView(
      showGlows: true,
      child: SizedBox(
        height: screenHeight,
        width: double.infinity,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: AnimatedTextKit(
                  animatedTexts: [
                    TyperAnimatedText(
                      "Messages",
                      textStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                      speed: const Duration(milliseconds: 100),
                    ),
                  ],
                  totalRepeatCount: 1,
                ),
              ),
              const SizedBox(height: 20),
              
              StreamBuilder<UserModel>(
                stream: firestoreService.getUserStream(currentUserId),
                builder: (context, meSnapshot) {
                  return StreamBuilder<List<UserModel>>(
                    stream: firestoreService.getAllUsers(),
                    builder: (context, chatSnapshot) {
                      // Check for errors
                      if (meSnapshot.hasError || chatSnapshot.hasError) {
                        return Container(
                          height: 300,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline_rounded, color: Colors.red.withValues(alpha: 0.5), size: 48),
                              const SizedBox(height: 16),
                              Text(
                                "Something went wrong",
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                              ),
                              const SizedBox(height: 16),
                              TextButton.icon(
                                onPressed: () {
                                  // This will trigger a rebuild of the streams
                                  (context as Element).markNeedsBuild();
                                }, 
                                icon: const Icon(Icons.refresh_rounded, size: 18),
                                label: const Text("Retry"),
                                style: TextButton.styleFrom(foregroundColor: const Color(0xFF2E8AF6)),
                              )
                            ],
                          ),
                        );
                      }

                      // Check for loading
                      if (meSnapshot.connectionState == ConnectionState.waiting || 
                          chatSnapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 500,
                          child: AppLoadingIndicator(isFullScreen: false),
                        );
                      }

                      final myFriends = meSnapshot.data?.friends ?? [];
                      final users = chatSnapshot.data
                              ?.where((u) => u.id != currentUserId && myFriends.contains(u.id))
                              .toList() ?? [];

                      // Check for empty
                      if (users.isEmpty) {
                        return Container(
                          height: 300,
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline_rounded, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1), size: 64),
                              const SizedBox(height: 16),
                              Text(
                                "No connections yet.\nAccepted requests will appear here.",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), height: 1.5),
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: users.map((user) => ChatUserTile(
                          user: user, 
                          currentUserId: currentUserId
                        )).toList(),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatUserTile extends StatelessWidget {
  final UserModel user;
  final String currentUserId;
  const ChatUserTile({super.key, required this.user, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final chatService = ChatService();
    final chatId = chatService.getChatRoomId(currentUserId, user.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        onTap: () => context.push(AppRoutes.chat, extra: user),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AppAvatar(
                  imageUrl: user.photoURL,
                  customSize: 48,
                  initials: user.username.isNotEmpty ? user.username[0] : '?',
                ),
                StreamBuilder<int>(
                  stream: chatService.getUnreadCountFromChatStream(chatId, currentUserId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data! > 0) {
                      return Positioned(
                        right: 0, top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF3B30),
                            shape: BoxShape.circle,
                            border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                          ),
                          constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.username, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 4),
                StreamBuilder<int>(
                  stream: chatService.getUnreadCountFromChatStream(chatId, currentUserId),
                  builder: (context, unreadSnapshot) {
                    if (unreadSnapshot.hasData && unreadSnapshot.data! > 0) {
                      return Text("${unreadSnapshot.data} new messages", style: const TextStyle(color: Color(0xFFFF3B30), fontSize: 12, fontWeight: FontWeight.bold));
                    }
                    return Text(user.isOnline ? "Online Now" : "Offline", style: TextStyle(color: user.isOnline ? const Color(0xFF00FF94) : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12));
                  },
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05), shape: BoxShape.circle),
              child: Icon(Icons.arrow_forward_ios_rounded, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), size: 14),
            ),
          ],
        ),
      ),
    );
  }
}
