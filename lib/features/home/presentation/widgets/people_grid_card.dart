import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

import 'package:chat_app/core/widgets/common/tactile_feedback.dart';
import 'package:chat_app/core/widgets/common/pulsing_status.dart';

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
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Avatar with Green Ring
                          // Avatar with Premium Gradient Ring
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
                                      colors: [Color(0xFF2563EB), Color(0xFF22D3EE)],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF2563EB).withValues(alpha: 0.6),
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
                                    color: Theme.of(context).cardTheme.color, // Match card bg
                                  ),
                                ),
                                // 3. Avatar Image
                                Hero(
                                  tag: 'avatar_${user.id}',
                                  child: CircleAvatar(
                                    radius: avatarRadius.clamp(20.0, 48.0), 
                                    backgroundColor: Colors.transparent,
                                    backgroundImage: (user.photoURL != null && user.photoURL!.isNotEmpty) ? NetworkImage(user.photoURL!) : null,
                                    child: (user.photoURL == null || user.photoURL!.isEmpty) 
                                      ? Text(
                                          user.username.isNotEmpty ? user.username[0].toUpperCase() : '?', 
                                          style: TextStyle(
                                            fontSize: (avatarRadius * 0.8).clamp(14.0, 32.0), 
                                            color: Theme.of(context).colorScheme.primary, 
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: -0.5,
                                          )
                                        )
                                      : null,
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
                        
                        // Name
                        Text(
                          user.username, 
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface, 
                            fontWeight: FontWeight.w800, 
                            fontSize: nameFontSize.clamp(12.0, 18.0),
                            letterSpacing: -0.5,
                          ), 
                          textAlign: TextAlign.center, 
                          maxLines: 1, 
                          overflow: TextOverflow.ellipsis
                        ),
                        
                        SizedBox(height: 4),
                        
                        // Role/Subtitle
                        Text(
                          user.role,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), 
                            fontSize: roleFontSize.clamp(10.0, 14.0),
                            letterSpacing: 0.1,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const Spacer(),
                        
                        // "View profile" Label
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "View Profile",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary, 
                                fontSize: (cardWidth * 0.065).clamp(10.0, 14.0),
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
