import 'package:chat_app/core/widgets/common/tactile_feedback.dart';
import 'package:flutter/material.dart';

class ChatInputArea extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const ChatInputArea({
    super.key, 
    required this.controller, 
    required this.onSend
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 32, top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
           BoxShadow(
             color: Colors.black.withValues(alpha: 0.4),
             blurRadius: 20,
             offset: const Offset(0, 10)
           )
        ]
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
           Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 10,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              cursorColor: const Color(0xFF2563EB),
              scrollPhysics: const BouncingScrollPhysics(),
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: "Write your message",
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                border: InputBorder.none,
                filled : false,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                isDense : false,
                contentPadding : EdgeInsets.zero,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          TactileFeedback(
            onTap: onSend,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF22D3EE)]),
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
