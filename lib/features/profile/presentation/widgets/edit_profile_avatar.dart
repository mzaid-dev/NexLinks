import 'package:image_picker/image_picker.dart';
import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show File;

class EditProfileAvatar extends StatelessWidget {
  final UserModel user;
  final XFile? localImage;
  final VoidCallback? onTap;

  const EditProfileAvatar({
    super.key, 
    required this.user, 
    this.localImage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
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
                        color: const Color(0xFF2563EB).withOpacity(0.5),
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
            // Camera Badge
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF00FF94),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    color: Colors.black, size: 14),
              ),
            )
          ],
        ),
      ),
    );
  }

  ImageProvider? _getAvatarImage() {
    if (localImage != null) {
      if (kIsWeb) {
        return NetworkImage(localImage!.path);
      }
      return FileImage(File(localImage!.path));
    }
    if (user.photoURL != null && user.photoURL!.isNotEmpty) {
      return NetworkImage(user.photoURL!);
    }
    return null;
  }

  Widget? _getAvatarChild(BuildContext context) {
    if (localImage != null) return null;
    if (user.photoURL != null && user.photoURL!.isNotEmpty) return null;

    return Text(
      user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
      style: TextStyle(
          fontSize: 40,
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold),
    );
  }
}
