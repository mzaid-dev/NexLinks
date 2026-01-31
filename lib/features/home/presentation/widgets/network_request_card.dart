import 'package:chat_app/core/widgets/common/app_button.dart';
import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:flutter/material.dart';

class NetworkRequestCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final bool isSent; // To change button text "Cancel" vs "Decline"

  const NetworkRequestCard({
    super.key, 
    required this.user, 
    required this.onAccept, 
    required this.onDecline,
    this.isSent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color, // Theme-aware card bg
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08)),
        boxShadow: [
           BoxShadow(
             color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.1),
             blurRadius: 10, offset: const Offset(0, 4)
           )
        ]
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            Container(
              padding: const EdgeInsets.all(1.5),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                   colors: [Color(0xFF2979FF), Color(0xFF00FF94)],
                   begin: Alignment.topLeft, end: Alignment.bottomRight
                ),
              ),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: Colors.transparent,
                backgroundImage: (user.photoURL != null && user.photoURL!.isNotEmpty) ? NetworkImage(user.photoURL!) : null,
                child: (user.photoURL == null || user.photoURL!.isEmpty) 
                  ? Text(user.username.isNotEmpty ? user.username[0].toUpperCase() : '?', 
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 20))
                  : null,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSent ? "Pending acceptance" : "Wants to connect",
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12),
                  ),
                ],
              ),
            ),
            
            // Actions
            if (!isSent) ...[
              // ACCEPT
              AppButton(
                text: "Accept",
                onPressed: onAccept,
                style: AppButtonStyle.secondary,
                width: 100,
                height: 40,
                borderRadius: 20,
              ),
              const SizedBox(width: 8),
              // DECLINE
              AppButton(
                text: "",
                onPressed: onDecline,
                style: AppButtonStyle.outlined,
                width: 40,
                height: 40,
                borderRadius: 20,
                icon: Icons.close,
              ),
            ] else ...[
               // CANCEL
               AppButton(
                 text: "Cancel",
                 onPressed: onDecline,
                 style: AppButtonStyle.outlined,
                 width: 100,
                 height: 40,
                 borderRadius: 20,
               ),
            ]
          ],
        ),
      ),
    );
  }
}
