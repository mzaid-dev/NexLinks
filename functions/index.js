const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * Triggers when a new call_session document is created.
 * Sends a high-priority FCM data message to the receiver's device
 * so they get a ringing notification even when the app is background/killed.
 */
exports.onCallCreated = functions.firestore
  .document("call_sessions/{channelId}")
  .onCreate(async (snap, context) => {
    const session = snap.data();
    const channelId = context.params.channelId;

    if (!session || !session.receiverId) {
      console.log("onCallCreated: missing session data, skipping.");
      return null;
    }

    try {
      // Fetch the receiver's FCM token from the users collection
      const receiverDoc = await admin
        .firestore()
        .collection("users")
        .doc(session.receiverId)
        .get();

      if (!receiverDoc.exists) {
        console.log(`onCallCreated: receiver ${session.receiverId} not found.`);
        return null;
      }

      const fcmToken = receiverDoc.data()?.fcmToken;
      if (!fcmToken || fcmToken.trim() === "") {
        console.log(`onCallCreated: receiver has no FCM token.`);
        return null;
      }

      // Build and send the FCM v1 message via Admin SDK (secure, server-side)
      const message = {
        token: fcmToken,
        // Data-only message so the app handles it in background handler
        data: {
          type: "call",
          channelId: channelId,
          callerId: session.callerId ?? "",
          callerName: session.callerName ?? "Unknown",
          callerAvatarUrl: session.callerAvatarUrl ?? "",
          callType: session.type ?? "voice",
        },
        android: {
          priority: "high",
          ttl: 30000, // 30 second TTL — matches the ringing timeout
        },
        apns: {
          headers: {
            "apns-priority": "10",
            "apns-expiration": "0",
          },
          payload: {
            aps: {
              contentAvailable: true,
              sound: "default",
            },
          },
        },
      };

      const response = await admin.messaging().send(message);
      console.log(`onCallCreated: FCM sent successfully. MessageId: ${response}`);
    } catch (error) {
      console.error("onCallCreated: Failed to send FCM message:", error);
    }

    return null;
  });

/**
 * Auto-cleanup: deletes call_session documents older than 1 hour
 * to prevent stale data accumulation in Firestore.
 * Runs every hour via Cloud Scheduler.
 */
exports.cleanupStaleSessions = functions.pubsub
  .schedule("every 60 minutes")
  .onRun(async () => {
    const cutoff = new Date(Date.now() - 60 * 60 * 1000); // 1 hour ago
    const snapshot = await admin
      .firestore()
      .collection("call_sessions")
      .where("createdAt", "<", cutoff)
      .get();

    if (snapshot.empty) {
      console.log("cleanupStaleSessions: No stale sessions found.");
      return null;
    }

    const batch = admin.firestore().batch();
    snapshot.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();
    console.log(`cleanupStaleSessions: Deleted ${snapshot.docs.length} stale sessions.`);
    return null;
  });
