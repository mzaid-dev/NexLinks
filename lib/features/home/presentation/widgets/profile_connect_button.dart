import 'package:chat_app/core/services/firestoreservice.dart';
import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:chat_app/router/route_names.dart';

class ProfileConnectButton extends StatelessWidget {
  final String currentUserId;
  final String viewedUserId;
  final UserModel? viewedUser; // Optional: passed to navigate to chat if needed immediately

  const ProfileConnectButton({
    super.key, 
    required this.currentUserId, 
    required this.viewedUserId,
    this.viewedUser
  });

  @override
  Widget build(BuildContext context) {
    // If viewing own profile, hide button or show Edit (but user specifically asked for relationship logic)
    if (currentUserId == viewedUserId) return const SizedBox.shrink();

    final firestoreService = context.read<FirestoreService>();

    return StreamBuilder<UserModel>(
      stream: firestoreService.getUserStream(currentUserId),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) return const SizedBox.shrink();

        final currentUser = userSnapshot.data!;
        
        // 1. Check if Already Friends
        if (currentUser.friends.contains(viewedUserId)) {
          return _buildButton(
            context: context,
            label: "Message",
            color: const Color(0xFF2E8AF6), // Primary Blue
            icon: Icons.chat_bubble_outline_rounded,
            onTap: () {
              if (viewedUser != null) {
                context.push(AppRoutes.chat, extra: viewedUser);
              }
            },
          );
        }

        // 2. Check Friend Requests
        return StreamBuilder<DocumentSnapshot>(
          stream: firestoreService.getFriendRequestStream(currentUserId, viewedUserId),
          builder: (context, requestSnapshot) {
            bool isLoading = requestSnapshot.connectionState == ConnectionState.waiting;
            if (isLoading && !requestSnapshot.hasData) {
               return Container(
                 height: 48, width: 48,
                 decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                 child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))),
               );
            }

            if (requestSnapshot.hasData && requestSnapshot.data!.exists) {
              final requestDoc = requestSnapshot.data!;
              final data = requestDoc.data() as Map<String, dynamic>;
              final status = data['status'];
              final fromId = data['from'];

              if (status == 'pending') {
                if (fromId == currentUserId) {
                  // State 2: Request Sent (Pending)
                  return _buildButton(
                    context: context,
                    label: "Pending",
                    color: Colors.grey,
                    icon: Icons.hourglass_empty_rounded,
                    isOutlined: true,
                    onTap: () {}, // No action
                  );
                } else {
                  // State 3: Request Received (Accept)
                  return _buildButton(
                    context: context,
                    label: "Accept Request",
                    color: const Color(0xFF00FF94), // Green
                    icon: Icons.check_rounded,
                    onTap: () async {
                      await firestoreService.acceptFriendRequest(requestDoc.id, currentUserId, viewedUserId);
                    },
                  );
                }
              }
            }

            // State 1: Not Connected
            return _buildButton(
              context: context,
              label: "Connect",
              color: const Color(0xFF2E8AF6),
              icon: Icons.person_add_rounded,
              onTap: () async {
                await firestoreService.sendFriendRequest(currentUserId, viewedUserId);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
    bool isOutlined = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: isOutlined ? Colors.transparent : color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isOutlined ? Colors.grey.withValues(alpha: 0.5) : color.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: isOutlined ? [] : [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4)
            )
          ]
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isOutlined ? Colors.grey : color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isOutlined ? Colors.grey : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16
              ),
            ),
          ],
        ),
      ),
    );
  }
}
