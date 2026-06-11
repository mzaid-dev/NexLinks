import 'package:nexlinks/core/widgets/common/app_loading_indicator.dart';
import 'dart:async';
import 'package:nexlinks/core/services/auth_service.dart';
import 'package:nexlinks/features/auth/data/models/user_model.dart';
import 'package:nexlinks/features/chat/data/chat_service.dart';
import 'package:nexlinks/features/chat/data/models/chat_message.dart';
import 'package:nexlinks/features/chat/logic/chat_cubit.dart';
import 'package:nexlinks/features/chat/presentation/widgets/chat_input_area.dart';
import 'package:nexlinks/features/chat/presentation/widgets/chat_message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexlinks/core/widgets/common/app_base_view.dart';
import 'package:nexlinks/core/services/firestoreservice.dart';
import 'package:nexlinks/core/widgets/common/gradient_text.dart';
import 'package:nexlinks/core/widgets/common/app_avatar.dart';
import 'package:flutter_chat_reactions/flutter_chat_reactions.dart';
import 'package:nexlinks/features/calling/presentation/screens/call_screen.dart';

class ChatScreen extends StatelessWidget {
  final UserModel targetUser;

  const ChatScreen({super.key, required this.targetUser});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(ChatService()),
      child: ChatView(targetUser: targetUser),
    );
  }
}

class ChatView extends StatefulWidget {
  final UserModel targetUser;

  const ChatView({super.key, required this.targetUser});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _messageController = TextEditingController();
  final _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();
  late final ReactionsController _reactionsController;
  late String _chatId;
  late String _currentUserId;
  StreamSubscription? _messageSubscription;

  @override
  void initState() {
    super.initState();
    _currentUserId = context.read<AuthService>().currentUserId!;
    _reactionsController = ReactionsController(currentUserId: _currentUserId);
    _chatId = _chatService.getChatRoomId(_currentUserId, widget.targetUser.id);

    context.read<ChatCubit>().markMessagesAsRead(_chatId, _currentUserId);

    _messageSubscription = _chatService.getMessages(_chatId).listen((messages) {
      if (mounted) {
        context.read<ChatCubit>().markMessagesAsRead(_chatId, _currentUserId);
      }
    });
  }

  UserModel get initialTargetUser => widget.targetUser;

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _messageController.text;
    if (text.trim().isEmpty) return;

    context.read<ChatCubit>().sendMessage(
      _chatId,
      text,
      _currentUserId,
      widget.targetUser.id,
    );
    _messageController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return AppBaseView(
      showGlows: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            _buildChatHeader(context),

            Expanded(
              child: StreamBuilder<List<ChatMessage>>(
                stream: _chatService.getMessages(_chatId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const AppLoadingIndicator();
                  }

                  final messages = snapshot.data ?? [];

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == _currentUserId;
                      return ChatMessageBubble(
                        message: message,
                        isMe: isMe,
                        chatId: _chatId,
                        currentUserId: _currentUserId,
                        reactionsController: _reactionsController,
                      );
                    },
                  );
                },
              ),
            ),

            ChatInputArea(controller: _messageController, onSend: _sendMessage),
          ],
        ),
      ),
    );
  }

  Widget _buildChatHeader(BuildContext context) {
    return StreamBuilder<UserModel>(
      stream: context.read<FirestoreService>().getUserStream(
        widget.targetUser.id,
      ),
      builder: (context, snapshot) {
        final user = snapshot.data ?? widget.targetUser;
        return SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.1),
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF2979FF), Color(0xFF00FF94)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    padding: const EdgeInsets.all(1.5),
                    child: Hero(
                      tag: 'avatar_${user.id}',
                      child: AppAvatar(
                        imageUrl: user.photoURL,
                        customSize: 32,
                        initials: user.username.isNotEmpty
                            ? user.username[0]
                            : '?',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'name_hero_${user.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: AppGradientText(
                          user.username,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: user.isOnline
                                ? const Color(0xFF00F0FF)
                                : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user.isOnline ? "Online" : "Offline",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                
                // Voice Call Button
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CallScreen(
                          channelId: 'call_${_currentUserId}_${user.id}',
                          enableVideo: false,
                          remoteUsername: user.username,
                          remoteAvatarUrl: user.photoURL,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                      ),
                    ),
                    child: const Icon(
                      Icons.phone_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Video Call Button
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CallScreen(
                          channelId: 'call_${_currentUserId}_${user.id}',
                          enableVideo: true,
                          remoteUsername: user.username,
                          remoteAvatarUrl: user.photoURL,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                      ),
                    ),
                    child: const Icon(
                      Icons.videocam_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
