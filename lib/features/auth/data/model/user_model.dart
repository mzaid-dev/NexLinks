import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String username;
  final String photoURL;
  final bool isOnline;
  final Timestamp lastSeen; // Change from DateTime to Timestamp
  final Timestamp createdAt; // Change from DateTime to Timestamp

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.photoURL = "",
    this.isOnline = false,
    required this.lastSeen,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'photoURL': photoURL,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
      'createdAt': createdAt,
    };
  }

  static UserModel fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      photoURL: map['photoURL'] ?? '',
      isOnline: map['isOnline'] ?? false,
      lastSeen: map['lastSeen'] ?? Timestamp.now(), // Handle Timestamp
      createdAt: map['createdAt'] ?? Timestamp.now(), // Handle Timestamp
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? photoURL,
    bool? isOnline,
    Timestamp? lastSeen,
    Timestamp? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      photoURL: photoURL ?? this.photoURL,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}