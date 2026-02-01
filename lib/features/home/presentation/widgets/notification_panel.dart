import 'package:nexlinks/core/services/auth_service.dart';
import 'package:nexlinks/core/services/firestoreservice.dart';
import 'package:nexlinks/features/auth/data/models/user_model.dart';
import 'package:nexlinks/core/widgets/common/mysnakebar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationPanel extends StatelessWidget {
  const NotificationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();
    final currentUserId = context.read<AuthService>().currentUserId;

    if (currentUserId == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
         color: Theme.of(context).scaffoldBackgroundColor,
         borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
         border: Border(top: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1), width: 1))
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Fit content
        children: [
          // Handle Bar (Draggable Indicator)
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40, height: 4,
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          
          const SizedBox(height: 10),
          Text("Notifications", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          
          Expanded(
             child: StreamBuilder<QuerySnapshot>(
               stream: firestoreService.getIncomingRequestsStream(currentUserId),
               builder: (context, snapshot) {
                 if (snapshot.connectionState == ConnectionState.waiting) {
                   return const Center(child: CircularProgressIndicator());
                 }
                                  final requests = snapshot.data?.docs ?? [];

                  if (requests.isEmpty) {
                    return Center(child: Text("No new notifications", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))));
                  }

                  // Deduplication for legacy records
                  final seenSenders = <String>{};
                  final uniqueRequests = requests.where((doc) {
                    final fromId = doc['from'] as String;
                    if (seenSenders.contains(fromId)) return false;
                    seenSenders.add(fromId);
                    return true;
                  }).toList();

                  return ListView.builder(
                    itemCount: uniqueRequests.length,
                    itemBuilder: (context, index) {
                       final req = uniqueRequests[index];
                       final fromId = req['from'];
                       final reqId = req.id;

                       // Fetch User Helper
                       return FutureBuilder<UserModel?>(
                         future: firestoreService.getUser(fromId),
                         builder: (context, userSnap) {
                            if (!userSnap.hasData) return const SizedBox.shrink();
                            
                            final user = userSnap.data!;
                            
                            return _buildRequestItem(context, user, reqId, currentUserId);
                         }
                       );
                    },
                  );
               } 
             ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestItem(BuildContext context, UserModel user, String requestId, String currentUserId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05))
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(1.5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF2979FF), Color(0xFF00FF94)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.transparent,
              child: Text(user.username.isNotEmpty ? user.username[0].toUpperCase() : '?', 
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.username, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
                Text("Sent you a friend request", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12)),
              ],
            ),
          ),
          
          // Accept Button
          InkWell(
             onTap: () async {
                try {
                  await context.read<FirestoreService>().acceptFriendRequest(requestId, currentUserId, user.id);
                  if (context.mounted) {
                    MySnackBar.show(context: context, message: "Request Accepted", isError: false);
                  }
                } catch (e) {
                  // handle error
                }
             },
             child: Container(
               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
               decoration: BoxDecoration(color: const Color(0xFF00FF94).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
               child: const Text("Accept", style: TextStyle(color: Color(0xFF00FF94), fontSize: 12, fontWeight: FontWeight.bold)),
             ),
           ),
           
           const SizedBox(width: 8),
           
           // Reject Button
           InkWell(
             onTap: () async {
                try {
                  await context.read<FirestoreService>().rejectFriendRequest(requestId);
                  if (context.mounted) {
                     MySnackBar.show(context: context, message: "Request Rejected", isError: false);
                  }
                } catch (e) {
                   // error
                }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.close, color: Colors.red, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
