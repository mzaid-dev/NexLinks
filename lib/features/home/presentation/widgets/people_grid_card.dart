import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class PeopleGridCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;

  const PeopleGridCard({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).cardTheme.color,
          boxShadow: [
             // subtle glow
             BoxShadow(
               color: const Color(0xFF2563EB).withOpacity(0.1),
               blurRadius: 10,
               offset: const Offset(0, 4),
             )
          ],
        ),
        child: Stack(
          children: [
            // 1. Green Glow Gradient Top-Left (Matches image vibe)
            // Positioned(
            //   top: -40,
            //   left: -40,
            //   child: Container(
            //     width: 100, height: 100,
            //     decoration: BoxDecoration(
            //       shape: BoxShape.circle,
            //       // color: const Color(0xFF2E8AF6).withOpacity(0.4),
            //       boxShadow: [
            //         BoxShadow(
            //           color: const Color(0xFF2E8AF6).withOpacity(0.09),
            //           blurRadius: 40,
            //           spreadRadius: 10,
            //         )
            //       ]
            //     ),
            //   ),
            // ),

            // 2. Content
            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = constraints.maxWidth;
                final avatarRadius = cardWidth * 0.22;
                final nameFontSize = cardWidth * 0.09;
                final roleFontSize = cardWidth * 0.06;

                return FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
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
                                      color: const Color(0xFF2563EB).withOpacity(0.6),
                                      blurRadius: 20,
                                      spreadRadius: 1
                                    )
                                  ]
                                ),
                              ),
                              // 2. Spacer (Background)
                              Container(
                                width: avatarRadius * 2.28,
                                height: avatarRadius * 2.28,
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
                                          fontWeight: FontWeight.bold
                                        )
                                      )
                                    : null,
                                ),
                              ),
                            ],
                          ),
                        ),

                      SizedBox(height: cardWidth * 0.08),
                      
                      // Name
                      Text(
                        user.username, 
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface, 
                          fontWeight: FontWeight.w600, 
                          fontSize: nameFontSize.clamp(10.0, 18.0)
                        ), 
                        textAlign: TextAlign.center, 
                        maxLines: 1, 
                        overflow: TextOverflow.ellipsis
                      ),
                      
                      SizedBox(height: cardWidth * 0.02),
                      
                      // Role/Subtitle
                      Text(
                        user.role,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), 
                          fontSize: roleFontSize.clamp(8.0, 14.0)
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const Spacer(),
                      
                      // "View profile" Button (Pill)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: (cardWidth * 0.05).clamp(6.0, 10.0)),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.1))
                        ),
                        child: Text(
                          "View profile",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface, 
                            fontSize: (cardWidth * 0.065).clamp(9.0, 14.0)
                          ),
                          textAlign: TextAlign.center,
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
    );
  }
}
