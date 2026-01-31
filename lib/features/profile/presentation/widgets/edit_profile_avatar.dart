import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:chat_app/core/widgets/common/app_avatar.dart';
import 'package:flutter/material.dart';

class EditProfileAvatar extends StatelessWidget {
  final UserModel user;
  final String? selectedAvatarUrl;

  const EditProfileAvatar({
    super.key, 
    required this.user, 
    this.selectedAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final avatarUrl = (selectedAvatarUrl != null && selectedAvatarUrl!.isNotEmpty) 
        ? selectedAvatarUrl 
        : user.photoURL;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Premium Profile Ring
          Container(
            width: 114,
            height: 114,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF22D3EE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),
          // Inner Spacer
          Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
          // App Avatar Image
          AppAvatar(
            imageUrl: avatarUrl,
            customSize: 100,
            initials: user.username.isNotEmpty ? user.username[0] : '?',
          ),
          // Edit Icon Overlay
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
