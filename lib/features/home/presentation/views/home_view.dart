import 'package:nexlinks/core/widgets/common/app_button.dart';
import 'package:animate_do/animate_do.dart';
import 'package:nexlinks/core/services/auth_service.dart';
import 'package:nexlinks/core/services/firestoreservice.dart';
import 'package:nexlinks/core/widgets/common/app_avatar.dart';
import 'package:nexlinks/features/home/presentation/widgets/glass_card.dart';
import 'package:nexlinks/router/route_names.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthService>().currentUser;
    
    return AppBaseView(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            if (currentUser != null)
              StreamBuilder<UserModel>(
                stream: context.read<FirestoreService>().getUserStream(currentUser.uid),
                builder: (context, snapshot) {
                  final user = snapshot.data;
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Good Morning,", style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 16)),
                              const SizedBox(height: 4),
                              AnimatedTextKit(
                                animatedTexts: [
                                  TyperAnimatedText(
                                    user?.username ?? "User",
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
                      
                      // Industry Polish: Onboarding Hint for new users
                      if (user != null && (user.fullName == null || user.fullName!.isEmpty || (user.bio ?? "").isEmpty))
                        FadeInDown(
                          duration: const Duration(milliseconds: 600),
                          child: Container(
                            margin: const EdgeInsets.only(top: 24),
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
                    ],
                  );
                }
              ),
            const SizedBox(height: 32),
            const SizedBox(height: 24),
            // Header for recommended users
            Align(
              alignment: Alignment.centerLeft,
              child: AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    "People you may know",
                    textStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
                    speed: const Duration(milliseconds: 100),
                  ),
                ],
                totalRepeatCount: 1,
              ),
            ),
            const SizedBox(height: 16),
            const UserListSection(onlyFriends: false),
            const SizedBox(height: 100), // Bottom Padding for Nav
          ],
        ),
      ),
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
            
            if (users.isEmpty) {
              return AppEmptyState(
                icon: Icons.people_outline_rounded,
                title: "No users yet",
                message: "It looks like you're the first one here! Or at least, none of your friends are online.",
                onAction: () => context.push(AppRoutes.explore),
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
                    child: AppGradientText(
                      user.username, 
                      style: const TextStyle(fontWeight: FontWeight.bold)
                    ),
                  ),
                  Text(user.isOnline ? "Online Now" : "Offline", style: TextStyle(color: user.isOnline ? Colors.green : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12)),
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
