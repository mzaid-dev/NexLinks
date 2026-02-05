import 'package:animate_do/animate_do.dart';
import 'package:nexlinks/core/widgets/common/app_loading_indicator.dart';
import 'package:nexlinks/core/services/auth_service.dart';
import 'package:nexlinks/core/services/firestoreservice.dart';
import 'package:nexlinks/features/auth/data/models/user_model.dart';
import 'package:nexlinks/features/home/presentation/widgets/network_request_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class NetworkScreen extends StatelessWidget {
  const NetworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: AnimatedTextKit(
            animatedTexts: [
              TyperAnimatedText(
                "Network",
                textStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
                speed: const Duration(milliseconds: 100),
              ),
            ],
            totalRepeatCount: 1,
          ),
          centerTitle: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: const TabBar(
                labelColor: Color(0xFF2979FF),
                unselectedLabelColor: Colors.grey,
                indicatorColor: Color(0xFF2979FF),
                indicatorWeight: 3,
                labelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                tabs: [
                  Tab(text: "Received"),
                  Tab(text: "Sent"),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [_ReceivedRequestsTab(), _SentRequestsTab()],
        ),
      ),
    );
  }
}

class _ReceivedRequestsTab extends StatelessWidget {
  const _ReceivedRequestsTab();

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();
    final currentUserId = context.read<AuthService>().currentUserId;

    if (currentUserId == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getIncomingRequestsStream(currentUserId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const AppLoadingIndicator();

        final requests = snapshot.data!.docs;
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.2),
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  "No pending requests",
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            return FutureBuilder<UserModel?>(
              future: firestoreService.getUser(req['from']),
              builder: (context, userSnap) {
                if (!userSnap.hasData) {
                  return const SizedBox(
                    height: 80,
                    child: AppLoadingIndicator(),
                  );
                }

                return FadeInUp(
                  delay: Duration(milliseconds: index * 100),
                  child: NetworkRequestCard(
                    user: userSnap.data!,
                    onAccept: () async {
                      await firestoreService.acceptFriendRequest(
                        req.id,
                        currentUserId,
                        userSnap.data!.id,
                      );
                    },
                    onDecline: () async {
                      await firestoreService.rejectFriendRequest(req.id);
                    },
                    isSent: false,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _SentRequestsTab extends StatelessWidget {
  const _SentRequestsTab();

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();
    final currentUserId = context.read<AuthService>().currentUserId;

    if (currentUserId == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getSentRequestsStream(currentUserId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const AppLoadingIndicator();

        final requests = snapshot.data!.docs;
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.send_outlined,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.2),
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  "No sent requests",
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            return FutureBuilder<UserModel?>(
              future: firestoreService.getUser(req['to']),
              builder: (context, userSnap) {
                if (!userSnap.hasData) {
                  return const SizedBox(
                    height: 80,
                    child: AppLoadingIndicator(),
                  );
                }

                return FadeInUp(
                  delay: Duration(milliseconds: index * 100),
                  child: NetworkRequestCard(
                    user: userSnap.data!,
                    onAccept: () {},
                    onDecline: () async {
                      await firestoreService.cancelFriendRequest(req.id);
                    },
                    isSent: true,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
