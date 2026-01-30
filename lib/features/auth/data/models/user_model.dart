import 'package:chat_app/core/utils/date_parser.dart';
import 'package:chat_app/features/auth/domain/entities/auth_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel extends AuthUser {
  final Timestamp lastSeen;
  final Timestamp createdAt;
  final List<String> friends;
  final String role;
  final String? bio;

  const UserModel({
    required super.id,
    required super.email,
    required super.username,
    super.fullName,
    super.photoURL,
    super.isOnline,
    super.experienceYears,
    super.expertise,
    required this.lastSeen,
    required this.createdAt,
    this.friends = const [],
    this.role = 'user',
    this.bio,
  });

  int get sessionsCount => friends.length * 3; // Mock logic or based on data
  int get successRate => 85 + (friends.length % 15); // Mock logic or based on data

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'photoURL': photoURL,
      'bio': bio,
      'role': role,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
      'createdAt': createdAt,
      'fullName': fullName,
      'friends': friends,
      'experienceYears': experienceYears,
      'expertise': expertise,
    };
  }

  static UserModel fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      photoURL: map['photoURL'] ?? '',
      bio: map['bio'] ?? '',
      role: map['role'] ?? '',
      isOnline: map['isOnline'] ?? false,
      lastSeen: parseTimestamp(map['lastSeen']),
      createdAt: parseTimestamp(map['createdAt']),
      fullName: map['fullName'],
      friends: List<String>.from(map['friends'] ?? []),
      experienceYears: map['experienceYears'] ?? 0,
      expertise: List<String>.from(map['expertise'] ?? []),
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? fullName,
    String? photoURL,
    bool? isOnline,
    Timestamp? lastSeen,
    Timestamp? createdAt,
    List<String>? friends,
    String? role,
    String? bio,
    int? experienceYears,
    List<String>? expertise,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      photoURL: photoURL ?? this.photoURL,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      friends: friends ?? this.friends,
      role: role ?? this.role,
      bio: bio ?? this.bio,
      experienceYears: experienceYears ?? this.experienceYears,
      expertise: expertise ?? this.expertise,
    );
  }
}