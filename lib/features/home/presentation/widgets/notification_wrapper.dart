import 'dart:async';
import 'package:nexlinks/core/services/auth_service.dart';
import 'package:nexlinks/core/services/firestoreservice.dart';
import 'package:nexlinks/core/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationWrapper extends StatefulWidget {
  final Widget child;
  const NotificationWrapper({super.key, required this.child});

  @override
  State<NotificationWrapper> createState() => _NotificationWrapperState();
}

class _NotificationWrapperState extends State<NotificationWrapper>
    with WidgetsBindingObserver {
  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;
  final NotificationService _notificationService = NotificationService();
  StreamSubscription<QuerySnapshot>? _messageSubscription;
  StreamSubscription<QuerySnapshot>? _requestSubscription;
  late Timestamp _startTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTime = Timestamp.now();
    _notificationService.init();
    _listenForMessages();
    _listenForFriendRequests();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageSubscription?.cancel();
    _requestSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appLifecycleState = state;
  }

  void _listenForMessages() {
    final currentUserId = context.read<AuthService>().currentUserId;
    if (currentUserId == null) return;

    _messageSubscription = FirebaseFirestore.instance
        .collectionGroup('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen(
          (snapshot) {
            for (var change in snapshot.docChanges) {
              if (change.type == DocumentChangeType.added) {
                final data = change.doc.data() as Map<String, dynamic>;
                final timestamp = data['timestamp'] as Timestamp?;

                if (timestamp != null && timestamp.compareTo(_startTime) > 0) {
                  if (_appLifecycleState != AppLifecycleState.resumed) {
                    _notificationService.showNotification(
                      id: change.doc.hashCode,
                      title: "New Message",
                      body: data['text'] ?? "You have a new message",
                    );
                  }
                }
              }
            }
          },
          onError: (error) {
            debugPrint("NotificationWrapper Error (Messages): $error");
          },
        );
  }

  void _listenForFriendRequests() {
    final currentUserId = context.read<AuthService>().currentUserId;
    if (currentUserId == null) return;

    _requestSubscription = context
        .read<FirestoreService>()
        .getIncomingRequestsStream(currentUserId)
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final data = change.doc.data() as Map<String, dynamic>;
              final timestamp = data['timestamp'] as Timestamp?;

              if (timestamp != null && timestamp.compareTo(_startTime) > 0) {
                if (_appLifecycleState != AppLifecycleState.resumed) {
                  _notificationService.showNotification(
                    id: change.doc.hashCode,
                    title: "New Connection Request",
                    body: "Someone wants to connect with you!",
                  );
                }
              }
            }
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
