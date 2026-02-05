import 'package:flutter/material.dart';
import 'package:nexlinks/core/widgets/common/app_avatar.dart';
import 'package:nexlinks/core/widgets/common/gradient_text.dart';
import 'package:nexlinks/features/auth/data/models/user_model.dart';

class ProfileSliverHeader extends SliverPersistentHeaderDelegate {
  final UserModel user;
  final double expandedHeight;
  final double topPadding;

  ProfileSliverHeader({
    required this.user,
    required this.expandedHeight,
    required this.topPadding,
  });

  @override
  double get minExtent => kToolbarHeight + topPadding;

  @override
  double get maxExtent => expandedHeight;

  @override
  bool shouldRebuild(covariant ProfileSliverHeader oldDelegate) {
    return oldDelegate.user != user ||
        oldDelegate.expandedHeight != expandedHeight ||
        oldDelegate.topPadding != topPadding;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double percent = (shrinkOffset / (maxExtent - minExtent)).clamp(
      0.0,
      1.0,
    );

    final double opacity = (1 - percent).clamp(0.0, 1.0);

    final double avatarSize = (120 - (percent * 80)).clamp(40.0, 120.0);

    final double avatarTop = _lerp(
      (expandedHeight / 2) - 80,
      topPadding + 5,
      percent,
    );

    final double avatarLeft = _lerp(
      MediaQuery.of(context).size.width / 2 - 60,
      50,
      percent,
    );

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).scaffoldBackgroundColor.withValues(alpha: percent),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: percent * 0.1),
            width: 1,
          ),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: avatarTop,
            left: avatarLeft,
            child: SizedBox(
              width: avatarSize,
              height: avatarSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF2979FF).withValues(alpha: 0.8),
                          const Color(0xFF00FF94).withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  Container(
                    width: avatarSize * 0.94,
                    height: avatarSize * 0.94,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  ),

                  Hero(
                    tag: 'avatar_${user.id}',
                    child: AppAvatar(
                      imageUrl: user.photoURL,
                      customSize: avatarSize * 0.82,
                      initials: user.username.isNotEmpty
                          ? user.username[0]
                          : '?',
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: avatarTop + avatarSize + 16,
            left: 0,
            right: 0,
            child: Visibility(
              visible: opacity > 0.01,
              child: Opacity(
                opacity: opacity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppGradientText(
                      user.fullName?.isNotEmpty == true
                          ? user.fullName!
                          : user.username,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: topPadding,
            bottom: 0,
            left: 115,
            child: Visibility(
              visible: percent > 0.8,
              child: Center(
                child: Opacity(
                  opacity: ((percent - 0.8) * 5).clamp(0.0, 1.0),
                  child: Text(
                    user.fullName?.isNotEmpty == true
                        ? user.fullName!
                        : user.username,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }
}
