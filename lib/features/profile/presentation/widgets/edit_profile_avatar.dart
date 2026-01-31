import 'package:chat_app/features/auth/data/models/user_model.dart';
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
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Reference: Blue/Cyan Gradient Ring
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF22D3EE)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 2)
                ]),
          ),
          // spacer for ring effect
          Container(
            width: 114,
            height: 114,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
          // Avatar Image
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.transparent,
            backgroundImage: _getAvatarImage(),
            child: _getAvatarChild(context),
          ),
        ],
      ),
    );
  }

  ImageProvider? _getAvatarImage() {
    if (selectedAvatarUrl != null && selectedAvatarUrl!.isNotEmpty) {
      return NetworkImage(selectedAvatarUrl!);
    }
    return null;
  }

  Widget? _getAvatarChild(BuildContext context) {
    if (selectedAvatarUrl != null && selectedAvatarUrl!.isNotEmpty) return null;

    return Text(
      user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
      style: TextStyle(
          fontSize: 40,
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold),
    );
  }
}
