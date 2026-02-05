import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final String id;
  final String email;
  final String username;
  final String? fullName;
  final String? photoURL;
  final bool isOnline;

  final int experienceYears;
  final List<String> expertise;

  const AuthUser({
    required this.id,
    required this.email,
    required this.username,
    this.fullName,
    this.photoURL,
    this.isOnline = false,
    this.experienceYears = 0,
    this.expertise = const [],
  });

  @override
  List<Object?> get props => [
    id,
    email,
    username,
    fullName,
    photoURL,
    isOnline,
    experienceYears,
    expertise,
  ];
}
