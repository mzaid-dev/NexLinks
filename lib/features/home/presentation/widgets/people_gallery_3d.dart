import 'package:flutter/material.dart';
import 'package:flutter_gallery_3d/gallery3d.dart';
import 'package:go_router/go_router.dart';
import 'package:nexlinks/core/widgets/common/app_avatar.dart';
import 'package:nexlinks/core/widgets/common/gradient_text.dart';
import 'package:nexlinks/core/widgets/common/pulsing_status.dart';
import 'package:nexlinks/features/auth/data/models/user_model.dart';
import 'package:nexlinks/router/route_names.dart';

class PeopleGallery3D extends StatefulWidget {
  final List<UserModel> users;
  
  const PeopleGallery3D({super.key, required this.users});

  @override
  State<PeopleGallery3D> createState() => _PeopleGallery3DState();
}

class _PeopleGallery3DState extends State<PeopleGallery3D> {
  late Gallery3DController controller;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    controller = Gallery3DController(
      itemCount: widget.users.length,
      autoLoop: false,
      ellipseHeight: 0,
      minScale: 0.4,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.users.isEmpty) {
      return const SizedBox.shrink();
    }

    return Gallery3D(
      controller: controller,
      width: MediaQuery.of(context).size.width,
      height: 200,
      isClip: false,
      itemConfig: const GalleryItemConfig(
        width: 160,
        height: 220,
        radius: 24,
        isShowTransformMask: false,
      ),
      onItemChanged: (index) {
        setState(() {
          currentIndex = index;
        });
      },
      onClickItem: (index) {
        context.push(AppRoutes.profile, extra: widget.users[index]);
      },
      itemBuilder: (context, index) {
        final user = widget.users[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: const Color(0xFF1A1A1A), // Darker black for 3D effect
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar with Premium Gradient Ring
              SizedBox(
                width: 90,
                height: 90,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Gradient Ring
                    Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF22D3EE)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.6),
                            blurRadius: 20,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    // Spacer
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    // Avatar Image
                    Hero(
                      tag: 'avatar_${user.id}',
                      child: AppAvatar(
                        imageUrl: user.photoURL,
                        customSize: 72,
                        initials: user.username.isNotEmpty ? user.username[0] : '?',
                      ),
                    ),
                    // Online Status
                    if (user.isOnline)
                      const Positioned(
                        bottom: 4,
                        right: 4,
                        child: PulsingStatus(size: 10),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Name
              Hero(
                tag: 'name_hero_${user.id}',
                child: Material(
                  color: Colors.transparent,
                  child: AppGradientText(
                    user.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              
              // Role
              Text(
                user.role,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 11,
                  letterSpacing: 0.1,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              
              // View Profile
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "View Profile",
                    style: TextStyle(
                      color: const Color(0xFF22D3EE),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 10,
                    color: const Color(0xFF22D3EE),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
