import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nexlinks/features/calling/data/models/call_session_model.dart';
import 'package:nexlinks/features/calling/data/services/callkit_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");

  if (message.data['type'] == 'call') {
    final String channelId = message.data['channelId'] ?? '';
    final String callerId = message.data['callerId'] ?? '';
    final String callerName = message.data['callerName'] ?? 'Unknown Caller';
    final String callerAvatarUrl = message.data['callerAvatarUrl'] ?? '';
    final String callTypeStr = message.data['callType'] ?? 'voice';

    final session = CallSession(
      id: channelId,
      callerId: callerId,
      callerName: callerName,
      callerAvatarUrl: callerAvatarUrl,
      receiverId: '',
      status: CallStatus.ringing,
      type: callTypeStr == 'video' ? CallType.video : CallType.voice,
      createdAt: DateTime.now(),
    );

    await CallKitService.showIncomingCall(session);
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _chatChannelId = 'chat_channel_id';
  static const String _callChannelId = 'call_channel_id';

  Future<void> init() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else {
      debugPrint('User declined or has not accepted permission');
      return;
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: false,
          requestBadgePermission: false,
          requestAlertPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse response) async {},
    );

    if (!kIsWeb) {
      await _createNotificationChannels();
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a foreground message: ${message.data}');

      // Incoming call while app is open — show in-app call banner
      if (message.data['type'] == 'call') {
        final callerName = message.data['callerName'] ?? 'Unknown Caller';
        final callTypeStr = message.data['callType'] ?? 'voice';
        showIncomingCallNotification(
          callerName: callerName,
          isVideo: callTypeStr == 'video',
        );
        return;
      }

      if (message.notification != null) {
        _showRemoteNotification(message);
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    String? token = await _firebaseMessaging.getToken();
    debugPrint("FCM Token: $token");
  }

  Future<void> _createNotificationChannels() async {
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _chatChannelId,
        'Chat Notifications',
        description: 'Notifications for incoming messages',
        importance: Importance.high,
      ),
    );

    // Max-importance channel so Android shows heads-up banner for calls
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _callChannelId,
        'Incoming Call Notifications',
        description: 'Notifications for incoming voice and video calls',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      ),
    );
  }

  /// Shows a heads-up / full-screen notification for an incoming call.
  /// When the app is in the foreground, Android renders this as a
  /// peek banner at the top of the screen.
  Future<void> showIncomingCallNotification({
    required String callerName,
    bool isVideo = false,
  }) async {
    if (kIsWeb) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _callChannelId,
      'Incoming Call Notifications',
      channelDescription: 'Notifications for incoming voice and video calls',
      importance: Importance.max,
      priority: Priority.max,
      ticker: 'Incoming Call',
      fullScreenIntent: true,
      category: AndroidNotificationCategory.call,
      visibility: NotificationVisibility.public,
      showWhen: false,
      color: Color(0xFF00FF94),
      ongoing: false,
      autoCancel: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      999,
      '📞 Incoming ${isVideo ? "Video" : "Voice"} Call',
      callerName,
      notificationDetails,
      payload: 'incoming_call',
    );
  }

  /// Dismiss the call notification when the call is accepted or declined.
  Future<void> cancelCallNotification() async {
    if (kIsWeb) return;
    await _notificationsPlugin.cancel(999);
  }

  Future<void> _showRemoteNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            _chatChannelId,
            'Chat Notifications',
            channelDescription: 'Notifications for incoming messages',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      await _notificationsPlugin.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: platformChannelSpecifics,
        payload: 'item x',
      );
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          _chatChannelId,
          'Chat Notifications',
          channelDescription: 'Notifications for incoming messages',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
      payload: payload,
    );
  }
}
