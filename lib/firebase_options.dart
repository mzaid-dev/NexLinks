import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBVmQjiFsU4dtZULV0oNOWvLGUg3lGEXMY',
    appId: '1:322014483549:web:ca3ad8353b3c8b4bef29b4',
    messagingSenderId: '322014483549',
    projectId: 'chat-app-478ce',
    authDomain: 'chat-app-478ce.firebaseapp.com',
    storageBucket: 'chat-app-478ce.firebasestorage.app',
    measurementId: 'G-RX19NE7C91',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyALYvMUsM_jLyTCFPZdbGDoZxg8__YmOGY',
    appId: '1:322014483549:android:7ab6bb1021520e8fef29b4',
    messagingSenderId: '322014483549',
    projectId: 'chat-app-478ce',
    storageBucket: 'chat-app-478ce.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDgVDHcNdy2G80rR7xjGchfRqn23Us8MIE',
    appId: '1:322014483549:ios:7438507632a1f15bef29b4',
    messagingSenderId: '322014483549',
    projectId: 'chat-app-478ce',
    storageBucket: 'chat-app-478ce.firebasestorage.app',
    iosBundleId: 'com.example.chatApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDgVDHcNdy2G80rR7xjGchfRqn23Us8MIE',
    appId: '1:322014483549:ios:7438507632a1f15bef29b4',
    messagingSenderId: '322014483549',
    projectId: 'chat-app-478ce',
    storageBucket: 'chat-app-478ce.firebasestorage.app',
    iosBundleId: 'com.example.chatApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBVmQjiFsU4dtZULV0oNOWvLGUg3lGEXMY',
    appId: '1:322014483549:web:57bd30aa3a9ea43def29b4',
    messagingSenderId: '322014483549',
    projectId: 'chat-app-478ce',
    authDomain: 'chat-app-478ce.firebaseapp.com',
    storageBucket: 'chat-app-478ce.firebasestorage.app',
    measurementId: 'G-VT17SMGBQX',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyBVmQjiFsU4dtZULV0oNOWvLGUg3lGEXMY',
    appId: '1:322014483549:web:57bd30aa3a9ea43def29b4',
    messagingSenderId: '322014483549',
    projectId: 'chat-app-478ce',
    authDomain: 'chat-app-478ce.firebaseapp.com',
    storageBucket: 'chat-app-478ce.firebasestorage.app',
    measurementId: 'G-VT17SMGBQX',
  );
}
