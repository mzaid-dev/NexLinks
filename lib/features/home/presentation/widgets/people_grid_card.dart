import 'package:nexlinks/features/auth/data/models/user_model.dart';
import 'package:nexlinks/core/widgets/common/app_avatar.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

import 'package:nexlinks/core/widgets/common/tactile_feedback.dart';
import 'package:nexlinks/core/widgets/common/pulsing_status.dart';
import 'package:nexlinks/core/widgets/common/gradient_text.dart';

class PeopleGridCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;

  const PeopleGridCard({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TactileFeedback(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32), // High-fidelity radius
          color: Theme.of(context).cardTheme.color,
          border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
          boxShadow: [
             BoxShadow(
               color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
               blurRadius: 24,
               offset: const Offset(0, 8),
             )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              // Content - fill the entire card for proper centering
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = constraints.maxWidth;

                    // Proportional sizing based on the actual available space
                    final avatarSize = (cardWidth * 0.45).clamp(60.0, 90.0);
                    final nameFontSize = (cardWidth * 0.09).clamp(14.0, 18.0);
                    final roleFontSize = (cardWidth * 0.07).clamp(11.0, 13.0);

                    return FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Use vertical space efficiently
                          children: [
                            // 1. Avatar Section
                            Expanded(
                              flex: 5,
                              child: Center(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Gradient Ring
                                    Container(
                                      width: avatarSize + 8,
                                      height: avatarSize + 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF2979FF), Color(0xFF00FF94)],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                    // Inner Gap
                                    Container(
                                      width: avatarSize + 4,
                                      height: avatarSize + 4,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context).cardTheme.color,
                                      ),
                                    ),
                                    // Actual Avatar
                                    Hero(
                                      tag: 'avatar_${user.id}',
                                      child: AppAvatar(
                                        imageUrl: user.photoURL,
                                        customSize: avatarSize,
                                        initials: user.username.isNotEmpty ? user.username[0] : '?',
                                      ),
                                    ),
                                    // Online indicator
                                    if (user.isOnline)
                                      Positioned(
                                        bottom: 2,
                                        right: 2,
                                        child: const PulsingStatus(size: 10),
                                      ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // 2. Info Section
                            Expanded(
                              flex: 4,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Hero(
                                    tag: 'name_hero_${user.id}',
                                    child: Material(
                                      color: Colors.transparent,
                                      child: AppGradientText(
                                        user.fullName?.isNotEmpty == true ? user.fullName! : user.username,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: nameFontSize,
                                          letterSpacing: -0.4,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  if (user.role.isNotEmpty && user.role.toLowerCase() != 'user') ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      user.role,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                                        fontSize: roleFontSize,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const Spacer(),
                                  // "View profile" Label - Slimmer and more Pinterest-style
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "View",
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 10,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
