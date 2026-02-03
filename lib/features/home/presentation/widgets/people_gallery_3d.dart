import 'package:flutter/material.dart';
import 'package:flutter_gallery_3d/gallery3d.dart';
import 'package:go_router/go_router.dart';
import 'package:nexlinks/core/widgets/common/app_avatar.dart';
import 'package:nexlinks/core/widgets/common/pulsing_status.dart';
import 'package:nexlinks/core/widgets/common/tactile_feedback.dart';
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

  @override
  void initState() {
    super.initState();
    controller = Gallery3DController(
      itemCount: widget.users.length,
      autoLoop: false,
      ellipseHeight: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.users.isEmpty) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    
    // Calculate dimensions exactly like Explore View grid items
    // (Screen - 20 pad left - 20 pad right - 16 spacing) / 2
    final gridCardWidth = (screenWidth - 56) / 2;
    // Aspect ratio from explore_view.dart (0.75 usually)
    final ratio = screenWidth < 380 ? 0.7 : 0.75;
    final gridCardHeight = gridCardWidth / ratio;

    return SizedBox(
      height: gridCardHeight, // Add padding for shadow/stacking
      child: Gallery3D(
        controller: controller,
        width: screenWidth,
        height: gridCardHeight + 30,
        isClip: false,
        onItemChanged: (index) {},
        itemConfig: GalleryItemConfig(
          width: gridCardWidth,
          height: gridCardHeight,
          radius: 32,
          isShowTransformMask: true, // Adds depth shadow
        ),
        onClickItem: (index) {
          context.push(AppRoutes.profile, extra: widget.users[index]);
        },
        itemBuilder: (context, index) {
          return _buildUserCard(widget.users[index]);
        },
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return TactileFeedback(
      onTap: () => context.push(AppRoutes.profile, extra: user),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: const Color(0xFF1A1A1A),
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
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            const Color(0xFF22D3EE),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    // Avatar
                    Hero(
                      tag: 'avatar_${user.id}',
                      child: AppAvatar(
                        size: AppAvatarSize.large,
                        imageUrl: user.photoURL,
                      ),
                    ),
                    // Online Status with Pulsing Animation
                    if (user.isOnline)
                      const Positioned(
                        bottom: 2,
                        right: 2,
                        child: PulsingStatus(),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Name with Hero Animation
              Hero(
                tag: 'name_${user.id}',
                child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      user.fullName?.isNotEmpty == true ? user.fullName! : user.username,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // Role
              Text(
                user.role.isNotEmpty ? user.role : "Developer",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),

              // View Profile
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "View Profile",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
