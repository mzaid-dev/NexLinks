importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
 apiKey: 'AIzaSyBVmQjiFsU4dtZULV0oNOWvLGUg3lGEXMY',
    appId: '1:322014483549:web:ca3ad8353b3c8b4bef29b4',
    messagingSenderId: '322014483549',
    projectId: 'chat-app-478ce',
    authDomain: 'chat-app-478ce.firebaseapp.com',
    storageBucket: 'chat-app-478ce.firebasestorage.app',
    measurementId: 'G-RX19NE7C91',
});

const messaging = firebase.messaging();

// Optional: Handle background messages
messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png' // Ensure you have an icon in web/icons/
  };

  return self.registration.showNotification(notificationTitle,
    notificationOptions);
});