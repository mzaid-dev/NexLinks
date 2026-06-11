import 'package:cloud_firestore/cloud_firestore.dart';

Timestamp parseTimestamp(dynamic value) {
  try {
    if (value is Timestamp) {
      return value;
    } else if (value is int) {
      return Timestamp.fromMillisecondsSinceEpoch(value);
    } else if (value is String) {
      return Timestamp.now();
    }
  } catch (e) {
    return Timestamp.now();
  }
  return Timestamp.now();
}
