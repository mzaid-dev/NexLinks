import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nexlinks/core/widgets/common/app_avatar.dart';
import 'package:nexlinks/core/widgets/common/tactile_feedback.dart';
import 'package:nexlinks/features/auth/data/models/user_model.dart';
import 'package:nexlinks/features/home/presentation/widgets/glass_card.dart';
import 'package:nexlinks/router/route_names.dart';

class ModernPeopleCarousel extends StatefulWidget {
  final List<UserModel> users;
  const ModernPeopleCarousel({super.key, required this.users});

  @override
  State<ModernPeopleCarousel> createState() => _ModernPeopleCarouselState();
}

class _ModernPeopleCarouselState extends State<ModernPeopleCarousel> {
  late PageController _pageController;
  int _realIndex = 1000; // Start at a high number for infinite feel

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.7, // Professional peeking
      initialPage: _realIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.users.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 400,
      child: PageView.builder(
        controller: _pageController,
        itemCount: 10000, 
        itemBuilder: (context, index) {
          final userIndex = index % widget.users.length;
          final user = widget.users[userIndex];

          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double page = 0.0;
              if (_pageController.position.haveDimensions) {
                page = _pageController.page!;
              } else {
                page = _realIndex.toDouble();
              }

              double value = (page - index);
              double absValue = value.abs();

              // 1. Scale Logic: Active 1.0 -> Side 0.8
              double scale = (1 - (absValue * 0.2)).clamp(0.8, 1.0);
              
              // 2. Blur Logic: Active 0.0 -> Side 6.0
              double blurSigma = (absValue * 6.0).clamp(0.0, 6.0);
              
              // 3. Opacity Logic: Active 1.0 -> Side 0.4
              double opacity = (1 - (absValue * 0.6)).clamp(0.4, 1.0);

              // 4. Translation/Stacked Logic: Tucking behind
              // Higher value means more horizontal compression
              double translation = value * 40.0; 

              bool isActive = absValue < 0.2;

              return Center(
                child: Container(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // Perspective
                    ..translate(translation) 
                    ..scale(scale),
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                    child: Opacity(
                      opacity: opacity,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Neon Glow (Standard Widget for stability)
                          if (isActive)
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2979FF).withValues(alpha: 0.15),
                                    blurRadius: 100,
                                    spreadRadius: 30,
                                  ),
                                ],
                              ),
                            ),
                          
                          _buildUserCard(user, isActive),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildUserCard(UserModel user, bool isActive) {
    return TactileFeedback(
      onTap: isActive ? () => context.push(AppRoutes.profile, extra: user) : null,
      child: GlassCard(
        borderRadius: 32,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar with Premium Gradient Ring
            Container(
              padding: const EdgeInsets.all(3.5),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF2979FF), Color(0xFF00FF94)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: Hero(
                  tag: 'avatar_${user.id}',
                  child: AppAvatar(
                    imageUrl: user.photoURL,
                    customSize: 86,
                    initials: user.username.isNotEmpty ? user.username[0] : '?',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              user.fullName?.isNotEmpty == true ? user.fullName! : user.username,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              user.role.isNotEmpty ? user.role.toUpperCase() : "EXPLORER",
              style: const TextStyle(
                color: Color(0xFF2979FF),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            
            // View Profile Button (Only interactive on active card)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isActive ? 1.0 : 0.0,
              child: IgnorePointer(
                ignoring: !isActive,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2979FF).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF2979FF).withValues(alpha: 0.1)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "View Profile",
                        style: TextStyle(
                          color: Color(0xFF2979FF),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF2979FF)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
