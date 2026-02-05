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
          borderRadius: BorderRadius.circular(32),
          color: Theme.of(context).cardTheme.color,
          border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
          boxShadow: [
             BoxShadow(
               color: const Color(0xFF2979FF).withValues(alpha: 0.08),
               blurRadius: 24,
               offset: const Offset(0, 8),
             )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              // Content
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = constraints.maxWidth;
                  final avatarRadius = cardWidth * 0.22;
                  final nameFontSize = cardWidth * 0.09;
                  final roleFontSize = cardWidth * 0.06;

                  return FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Avatar Section with High-Fidelity Glow
                          SizedBox(
                            width: avatarRadius * 2.5,
                            height: avatarRadius * 2.5,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // 1. Gradient Ring
                                Container(
                                  width: avatarRadius * 2.4,
                                  height: avatarRadius * 2.4,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF2979FF), Color(0xFF00FF94)],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF2979FF).withValues(alpha: 0.6),
                                        blurRadius: 20,
                                        spreadRadius: 1
                                      )
                                    ]
                                  ),
                                ),
                                // 2. Spacer (Background)
                                Container(
                                  width: avatarRadius * 2.24,
                                  height: avatarRadius * 2.24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).cardTheme.color,
                                  ),
                                ),
                                // 3. Avatar Image
                                Hero(
                                  tag: 'avatar_${user.id}',
                                  child: AppAvatar(
                                    imageUrl: user.photoURL,
                                    customSize: avatarRadius * 2,
                                    initials: user.username.isNotEmpty ? user.username[0] : '?',
                                  ),
                                ),
                                // 4. Online Status Indicator
                                if (user.isOnline)
                                  Positioned(
                                    bottom: 4,
                                    right: 4,
                                    child: const PulsingStatus(size: 10),
                                  ),
                              ],
                            ),
                          ),

                        SizedBox(height: cardWidth * 0.1),
                        
                        // Name with Hero and Gradient
                        AppGradientText(
                          user.username, 
                          style: TextStyle(
                            fontWeight: FontWeight.w800, 
                            fontSize: nameFontSize.clamp(12.0, 18.0),
                            letterSpacing: -0.5,
                          ), 
                          textAlign: TextAlign.center, 
                          maxLines: 1, 
                          overflow: TextOverflow.ellipsis
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Role
                        Text(
                          user.role.isNotEmpty ? user.role.toUpperCase() : "EXPLORER",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), 
                            fontSize: roleFontSize.clamp(10.0, 13.0),
                            letterSpacing: 0.1,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Modern Capsule Button (Matches Carousel Style)
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2979FF).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF2979FF).withValues(alpha: 0.1)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "View Profile",
                                  style: TextStyle(
                                    color: const Color(0xFF2979FF), 
                                    fontSize: (cardWidth * 0.065).clamp(10.0, 12.0),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  size: 14,
                                  color: Color(0xFF2979FF),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
            ],
          ),
        ),
      ),
    );
  }
}
