import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:chat_app/features/home/presentation/widgets/profile_connect_button.dart';
import 'package:chat_app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:chat_app/core/widgets/common/app_avatar.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel displayUser;
  final bool isMe;
  final String? currentUserId;

  const ProfileHeader({
    super.key,
    required this.displayUser,
    required this.isMe,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar Ring
        // Avatar with Premium Gradient Ring
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Gradient Ring
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                        colors: [Color(0xFF2979FF), Color(0xFF00FF94)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFF2979FF).withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 1)
                    ]),
              ),
              // 2. Spacer (Background)
              Container(
                width: 114,
                height: 114,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
              // 3. Avatar Image
              Hero(
                tag: 'avatar_${displayUser.id}',
                child: AppAvatar(
                  imageUrl: displayUser.photoURL,
                  customSize: 100,
                  initials: displayUser.username.isNotEmpty ? displayUser.username[0] : '?',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AnimatedTextKit(
          animatedTexts: [
            TyperAnimatedText(
              displayUser.fullName ?? displayUser.username,
              textStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
              speed: const Duration(milliseconds: 100),
            ),
          ],
          totalRepeatCount: 1,
        ),
        const SizedBox(height: 4),
        Text(displayUser.role, // "Cybersecurity Expert"
            style: const TextStyle(
                color: Color(0xFF2979FF), // Blue text
                fontSize: 16,
                fontWeight: FontWeight.w600)),

        const SizedBox(height: 12),
        
        const SizedBox(height: 12),
        
        const SizedBox(height: 20),

        // Edit Profile Button (Only if isMe)
        if (isMe)
          FadeInUp(
            duration: const Duration(milliseconds: 300),
            child: GestureDetector(
              onTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen(user: displayUser)));
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2979FF).withValues(alpha: 0.2), 
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: const Color(0xFF2979FF).withValues(alpha: 0.5)),
                ),
                child: const Text("Edit Profile",
                    style: TextStyle(
                        color: Color(0xFF2979FF), fontWeight: FontWeight.w600)),
              ),
            ),
          )
        else if (!isMe && currentUserId != null)
          // Connect Button for others
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ProfileConnectButton(
              currentUserId: currentUserId!,
              viewedUserId: displayUser.id,
              viewedUser: displayUser,
            ),
          ),
      ],
    );
  }
}
