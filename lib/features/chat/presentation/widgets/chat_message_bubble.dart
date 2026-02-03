import 'package:animate_do/animate_do.dart';
import 'package:flutter_chat_reactions/flutter_chat_reactions.dart';
import 'package:nexlinks/features/chat/data/models/chat_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexlinks/features/chat/logic/chat_cubit.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final String chatId;
  final String currentUserId;
  final ReactionsController reactionsController;

  const ChatMessageBubble({
    super.key, 
    required this.message, 
    required this.isMe,
    required this.chatId,
    required this.currentUserId,
    required this.reactionsController,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      from: 10,
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ChatMessageWrapper(
              messageId: message.id,
              controller: reactionsController,
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              config: const ChatReactionsConfig(
                // Remove Reply/Copy/Delete menu
                menuItems: [],
                // Remove the "+" button from reactions list
                availableReactions: ['👍', '❤️', '😂', '😮', '😢', '😠'],
              ),
              onReactionAdded: (reaction) {
                 context.read<ChatCubit>().toggleReaction(
                  chatId, 
                  message.id, 
                  currentUserId, 
                  reaction
                );
              },
              onReactionRemoved: (reaction) {
                // In our WhatsApp style logic, toggle handles both.
                // But we can specifically handle removal if needed.
                context.read<ChatCubit>().toggleReaction(
                  chatId, 
                  message.id, 
                  currentUserId, 
                  reaction
                );
              },
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  constraints: BoxConstraints(
                    minWidth: 70, // Prevent overflow for short messages with timestamp
                    maxWidth: MediaQuery.sizeOf(context).width * 0.7
                  ),
                decoration: isMe 
                  ? BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF22D3EE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(4),
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                      ),
                    ) 
                  : BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                      ),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.text,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.1,
                        decoration: TextDecoration.none, // Fix yellow underline
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          _formatTime(message.timestamp),
                          style: TextStyle(
                            // My messages: white, Friend's messages: cyan accent
                            color: isMe 
                                ? Colors.white.withValues(alpha: 0.8)
                                : const Color(0xFF22D3EE).withValues(alpha: 0.7), // Cyan accent
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            message.status == MessageStatus.pending
                                ? Icons.access_time_rounded  // Clock when pending
                                : message.isRead 
                                    ? Icons.done_all_rounded  // Double tick when read
                                    : Icons.done_rounded,     // Single tick when sent
                            size: 12,
                            // Read: bright cyan, Sent: white
                            color: message.isRead 
                                ? const Color(0xFF22D3EE) // Bright cyan for read (matches gradient)
                                : Colors.white.withValues(alpha: 0.8),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              ),
            ),
            
            // Reaction Chip Display
            if (message.reactions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 8),
                child: _buildReactionSummary(),
              )
            else
              const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionSummary() {
    final uniqueEmojis = message.reactions.values.toSet().toList();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            uniqueEmojis.take(3).join(' '),
            style: const TextStyle(fontSize: 12),
          ),
          if (message.reactions.length > 1) ...[
            const SizedBox(width: 4),
            Text(
              "${message.reactions.length}",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 10,
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    return "${date.hour % 12 == 0 ? 12 : date.hour % 12}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}";
  }
}
