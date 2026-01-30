import 'package:chat_app/core/widgets/common/app_loading_indicator.dart';
import 'dart:async';
import 'package:chat_app/core/services/auth_service.dart';
import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:chat_app/features/chat/data/chat_service.dart';
import 'package:chat_app/features/chat/data/models/chat_message.dart';
import 'package:chat_app/features/chat/logic/chat_cubit.dart';
import 'package:chat_app/features/chat/presentation/widgets/chat_input_area.dart';
import 'package:chat_app/features/chat/presentation/widgets/chat_message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/core/widgets/common/app_base_view.dart';

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
  late String _chatId;
  late String _currentUserId;
  StreamSubscription? _messageSubscription;

  @override
  void initState() {
    super.initState();
    _currentUserId = context.read<AuthService>().currentUserId!;
    _chatId = _chatService.getChatRoomId(_currentUserId, targetUser.id);
    
    // Initial mark as read
    context.read<ChatCubit>().markMessagesAsRead(_chatId, _currentUserId);

    // Listen to messages and mark as read in real-time
    _messageSubscription = _chatService.getMessages(_chatId).listen((messages) {
      if (mounted) {
        context.read<ChatCubit>().markMessagesAsRead(_chatId, _currentUserId);
      }
    });
  }

  UserModel get targetUser => widget.targetUser;

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

    context.read<ChatCubit>().sendMessage(_chatId, text, _currentUserId, targetUser.id);
    _messageController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return AppBaseView(
      showGlows: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            // Custom Header
            _buildChatHeader(context),

            // Messages
            Expanded(
              child: StreamBuilder<List<ChatMessage>>(
                stream: _chatService.getMessages(_chatId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
                  if (snapshot.connectionState == ConnectionState.waiting) return const AppLoadingIndicator();

                  final messages = snapshot.data ?? [];

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == _currentUserId;
                      return ChatMessageBubble(message: message, isMe: isMe);
                    },
                  );
                },
              ),
            ),

            // Input Area
            ChatInputArea(
              controller: _messageController,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatHeader(BuildContext context) {
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
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded, color: Theme.of(context).colorScheme.onSurface, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(1.2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF2979FF), Color(0xFF00FF94)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              ),
              child: Hero(
                tag: 'avatar_${targetUser.id}',
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.transparent,
                  child: Text(
                    targetUser.username.isNotEmpty ? targetUser.username[0].toUpperCase() : '?', 
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 14, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(targetUser.username, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        color: targetUser.isOnline ? const Color(0xFF00F0FF) : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(targetUser.isOnline ? "Online" : "Offline", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 11)),
                  ],
                ),
              ],
            ),
            const Spacer(),
            // Container(
            //   padding: const EdgeInsets.all(10),
            //   decoration: BoxDecoration(
            //     color: Colors.white.withOpacity(0.05),
            //     shape: BoxShape.circle,
            //     border: Border.all(color: Colors.white.withOpacity(0.1)),
            //   ),
            //   child: const Icon(Icons.search, color: Colors.white, size: 20),
            // ),
          ],
        ),
      ),
    );
  }
}
