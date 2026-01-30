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
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
        boxShadow: [
           BoxShadow(
             color: Colors.black.withOpacity(0.2),
             blurRadius: 10,
             offset: const Offset(0, 4)
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
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
              cursorColor: const Color(0xFF2E8AF6),
              scrollPhysics: const BouncingScrollPhysics(),
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: "Write your message",
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                border: InputBorder.none,
                filled : false,
                focusedBorder: InputBorder.none, // Kills the blue line on focus
                enabledBorder: InputBorder.none, // Kills the line when not focused
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                isDense : false,
                contentPadding : EdgeInsets.zero,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSend,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFF2E8AF6), 
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [Color(0xFF2E8AF6), Color(0xFF00F0FF)]),
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
