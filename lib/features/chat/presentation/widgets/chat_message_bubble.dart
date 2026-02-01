import 'package:animate_do/animate_do.dart';
import 'package:nexlinks/features/chat/data/models/chat_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const ChatMessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      from: 20,
      child: ZoomIn(
        duration: const Duration(milliseconds: 400),
        from: 0.95,
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.75),
            decoration: isMe 
              ? BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF22D3EE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(6),
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6)
                    )
                  ]
                ) 
              : BoxDecoration(
                  color: const Color(0xFF0D0D0D),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message.text,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Icon(
                        message.status == MessageStatus.pending
                            ? Icons.access_time_rounded
                            : Icons.done_all_rounded,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}
