import 'package:nexlinks/core/widgets/common/app_button.dart';
import 'package:animate_do/animate_do.dart';
import 'package:nexlinks/core/services/auth_service.dart';
import 'package:nexlinks/core/services/firestoreservice.dart';
import 'package:nexlinks/core/widgets/common/app_avatar.dart';
import 'package:nexlinks/features/home/presentation/widgets/glass_card.dart';
import 'package:nexlinks/features/home/presentation/widgets/people_gallery_3d.dart';
import 'package:nexlinks/router/route_names.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexlinks/features/home/logic/home_navigation_cubit.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nexlinks/core/widgets/common/app_base_view.dart';
import 'package:nexlinks/core/widgets/common/app_empty_state.dart';
import 'package:nexlinks/core/widgets/common/app_loading_indicator.dart';
import 'package:nexlinks/features/auth/data/models/user_model.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:nexlinks/core/widgets/common/gradient_text.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthService>().currentUser;
    if (currentUser == null) return const AppLoadingIndicator();
    
    return StreamBuilder<UserModel>(
      stream: context.read<FirestoreService>().getUserStream(currentUser.uid),
      builder: (context, userSnapshot) {
        final user = userSnapshot.data;
        
        return AppBaseView(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. YouTube-style Floating Header
              if (user != null)
                SliverAppBar(
                  floating: true,
                  snap: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  toolbarHeight: 110,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) => const LinearGradient(
                                      colors: [Color(0xFF2979FF), Color(0xFF00FF94)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds),
                                    child: Text(
                                      "Good Morning,", 
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.9), 
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  AnimatedTextKit(
                                    animatedTexts: [
                                      TyperAnimatedText(
                                        user.username,
                                        textStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.bold),
                                        speed: const Duration(milliseconds: 100),
                                      ),
                                    ],
                                    totalRepeatCount: 1,
                                  ),
                                ],
                              ),
                              GlassCard(
                                borderRadius: 50,
                                padding: const EdgeInsets.all(10),
                                onTap: () {
                                  context.push(AppRoutes.network);
                                },
                                child: Stack(
                                  children: [
                                    Icon(Icons.notifications_none_rounded, color: Theme.of(context).colorScheme.onSurface),
                                    StreamBuilder<QuerySnapshot>(
                                      stream: context.read<FirestoreService>().getIncomingRequestsStream(currentUser.uid),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                                           return Positioned(
                                             right: 2, top: 2,
                                             child: Container(
                                               width: 8, height: 8,
                                               decoration: const BoxDecoration(
                                                 color: Color(0xFF00FF94),
                                                 shape: BoxShape.circle,
                                               ),
                                             ),
                                           );
                                        }
                                        return const SizedBox.shrink();
                                      }
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // 2. Main Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Industry Polish: Onboarding Hint for new users
                      if (user != null && (user.fullName == null || user.fullName!.isEmpty || (user.bio ?? "").isEmpty))
                        FadeInDown(
                          duration: const Duration(milliseconds: 600),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF2979FF).withValues(alpha: 0.15),
                                  const Color(0xFF00FF94).withValues(alpha: 0.15),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFF2979FF).withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2979FF).withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF2979FF)),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Complete your profile", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
                                          Text("Help others find you by adding a bio and your skills.", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                AppButton(
                                  text: "Edit Profile Now",
                                  onPressed: () => context.push(AppRoutes.editProfile, extra: user),
                                  style: AppButtonStyle.primary,
                                  height: 48,
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 8),
                      
                      // 3D People Gallery Section
                      Align(
                        alignment: Alignment.centerLeft,
                        child: AnimatedTextKit(
                          animatedTexts: [
                            TyperAnimatedText(
                              "Discover People",
                              textStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              speed: const Duration(milliseconds: 100),
                            ),
                          ],
                          totalRepeatCount: 1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // 3D Gallery in Glass Container
                      if (user != null)
                        FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          child: GlassCard(
                            child: StreamBuilder<List<UserModel>>(
                              stream: context.read<FirestoreService>().getAllUsers(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const SizedBox(
                                    height: 200,
                                    child: Center(
                                      child: AppLoadingIndicator(isFullScreen: false, size: 30),
                                    ),
                                  );
                                }
        
                                final myFriends = user.friends;
                                // Get users who are NOT me AND NOT in my friends list
                                final allUsers = snapshot.data!
                                    .where((u) => u.id != currentUser.uid && !myFriends.contains(u.id))
                                    .toList();
                                allUsers.shuffle();
                                final randomUsers = allUsers.take(10).toList();
        
                                if (randomUsers.isEmpty) {
                                  return const SizedBox(
                                    height: 200,
                                    child: Center(
                                      child: Text(
                                        "No new people to discover",
                                        style: TextStyle(color: Colors.white54),
                                      ),
                                    ),
                                  );
                                }
        
                                return Center(
                                  child: PeopleGallery3D(users: randomUsers),
                                );
                              },
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 32),
                      // Header for recommended users
                      Align(
                        alignment: Alignment.centerLeft,
                        child: AnimatedTextKit(
                          animatedTexts: [
                            TyperAnimatedText(
                              "People you may know",
                              textStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              speed: const Duration(milliseconds: 100),
                            ),
                          ],
                          totalRepeatCount: 1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const UserListSection(onlyFriends: true),
                      const SizedBox(height: 100), // Bottom Padding for Nav
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

// Extracted UserList to separate widget for better SRP
class UserListSection extends StatelessWidget {
  final bool onlyFriends;
  const UserListSection({super.key, required this.onlyFriends});

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();
    final currentUserId = context.read<AuthService>().currentUserId;
    if (currentUserId == null) return const SizedBox.shrink();

    return StreamBuilder<UserModel>(
      stream: firestoreService.getUserStream(currentUserId),
      builder: (context, meSnapshot) {
        if (!meSnapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: AppLoadingIndicator(isFullScreen: false),
          );
        }
        final myFriends = meSnapshot.data?.friends ?? [];

        return StreamBuilder<List<UserModel>>(
          stream: firestoreService.getAllUsers(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: AppLoadingIndicator(isFullScreen: false),
              );
            }
            
            final users = snapshot.data!.where((u) {
              if (u.id == currentUserId) return false;
              if (onlyFriends) return myFriends.contains(u.id);
              return true;
            }).toList();

            // Industry Polish: Randomize and limit to 7-8 people from friends
            if (onlyFriends) {
              users.shuffle();
              if (users.length > 8) {
                users.removeRange(8, users.length);
              }
            }
            
            if (users.isEmpty) {
              return AppEmptyState(
                icon: Icons.people_outline_rounded,
                title: "No users yet",
                message: "It looks like you're the first one here! Or at least, none of your friends are online.",
                onAction: () => context.read<HomeNavigationCubit>().changeTab(1), // Switch to Explore Tab
                actionLabel: "Explore People",
              );
            }

            return Column(
              children: users.asMap().entries.map((entry) {
                final index = entry.key;
                final user = entry.value;
                return FadeInUp(
                  key: ValueKey(user.id),
                  delay: Duration(milliseconds: 400 + (index * 50)),
                  duration: const Duration(milliseconds: 600),
                  child: UserTile(user: user, currentUserId: currentUserId),
                );
              }).toList(),
            );
          },
        );
      }
    );
  }
}

class UserTile extends StatelessWidget {
  final UserModel user;
  final String currentUserId;
  const UserTile({super.key, required this.user, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        onTap: () => context.push(AppRoutes.profile, extra: user),
        child: Row(
          children: [
            Hero(
              tag: 'avatar_${user.id}',
              child: AppAvatar(
                imageUrl: user.photoURL,
                customSize: 48,
                initials: user.username.isNotEmpty ? user.username[0] : '?',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'name_hero_${user.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: AppGradientText(
                        user.username, 
                        style: const TextStyle(fontWeight: FontWeight.bold)
                      ),
                    ),
                  ),
                  Text(user.isOnline ? "Online Now" : "Offline", 
                    style: TextStyle(
                      color: user.isOnline 
                        ? const Color(0xFF00FF94) 
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), 
                      fontSize: 12,
                      fontWeight: user.isOnline ? FontWeight.bold : FontWeight.normal,
                    )
                  ),
                ],
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), size: 14),
          ],
        ),
      ),
    );
  }
}
