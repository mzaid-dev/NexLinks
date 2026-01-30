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
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08)),
        boxShadow: [
           BoxShadow(
             color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.1),
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
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 12),
                  ),
                ],
              ),
            ),
            
            // Actions
            if (!isSent) ...[
              // ACCEPT (Neo Blue Pill)
              InkWell(
                onTap: onAccept,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2979FF),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF2979FF).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 2))
                    ]
                  ),
                  child: Text("Accept", style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              // DECLINE (Outlined)
              InkWell(
                onTap: onDecline,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(Icons.close, color: Colors.grey, size: 18),
                ),
              )
            ] else ...[
               // CANCEL (Outlined)
               InkWell(
                onTap: onDecline, // Reuse decline as cancel
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text("Cancel", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 12)),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
