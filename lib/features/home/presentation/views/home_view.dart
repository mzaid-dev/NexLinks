import 'package:nexlinks/core/widgets/common/app_button.dart';
import 'package:animate_do/animate_do.dart';
import 'package:nexlinks/core/services/auth_service.dart';
import 'package:nexlinks/core/services/firestoreservice.dart';
import 'package:nexlinks/core/widgets/common/app_avatar.dart';
import 'package:nexlinks/features/home/presentation/widgets/glass_card.dart';
import 'package:nexlinks/features/home/presentation/widgets/modern_people_carousel.dart';
import 'package:nexlinks/router/route_names.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nexlinks/core/widgets/common/app_base_view.dart';
import 'package:nexlinks/core/widgets/common/app_loading_indicator.dart';
import 'package:nexlinks/features/auth/data/models/user_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<UserModel>? _randomUsers;
  List<UserModel>? _recommendedUsers;
  bool _isLoadingDiscovery = true;

  @override
  void initState() {
    super.initState();
    _fetchDiscoveryData();
  }

  Future<void> _fetchDiscoveryData() async {
    final firestoreService = context.read<FirestoreService>();
    final currentUserId = context.read<AuthService>().currentUserId;

    if (currentUserId == null) return;

    try {
      final allUsers = await firestoreService.getAllUsers().first;

      final me = await firestoreService.getUser(currentUserId);
      final myFriends = me?.friends ?? [];

      setState(() {
        final discoveryBase = allUsers
            .where((u) => u.id != currentUserId && !myFriends.contains(u.id))
            .toList();
        discoveryBase.shuffle();
        _randomUsers = discoveryBase.take(8).toList();

        final friendsList = allUsers
            .where((u) => u.id != currentUserId && myFriends.contains(u.id))
            .toList();
        if (friendsList.isEmpty) {
          _recommendedUsers = allUsers
              .where((u) => u.id != currentUserId)
              .toList();
          _recommendedUsers!.shuffle();
          _recommendedUsers = _recommendedUsers!.take(10).toList();
        } else {
          _recommendedUsers = friendsList;
        }

        _isLoadingDiscovery = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingDiscovery = false);
      }
    }
  }

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
              if (user != null)
                SliverAppBar(
                  floating: true,
                  snap: true,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  shadowColor: Colors.transparent,
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
                                    shaderCallback: (bounds) =>
                                        const LinearGradient(
                                          colors: [
                                            Color(0xFF2979FF),
                                            Color(0xFF00FF94),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ).createShader(bounds),
                                    child: Text(
                                      "Good Morning,",
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  ShaderMask(
                                    shaderCallback: (bounds) =>
                                        const LinearGradient(
                                          colors: [
                                            Colors.white,
                                            Color(0xFF2979FF),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ).createShader(bounds),
                                    child: Text(
                                      user.username,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              GlassCard(
                                borderRadius: 16,
                                padding: const EdgeInsets.all(12),
                                onTap: () {
                                  context.push(AppRoutes.network);
                                },
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Icon(
                                      Icons.notifications_none_rounded,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      size: 22,
                                    ),
                                    StreamBuilder<QuerySnapshot>(
                                      stream: context
                                          .read<FirestoreService>()
                                          .getIncomingRequestsStream(
                                            currentUser.uid,
                                          ),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData &&
                                            snapshot.data!.docs.isNotEmpty) {
                                          return Positioned(
                                            right: -2,
                                            top: -2,
                                            child: Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF00FF94),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Theme.of(
                                                    context,
                                                  ).scaffoldBackgroundColor,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      if (user != null &&
                          (user.fullName == null ||
                              user.fullName!.isEmpty ||
                              (user.bio ?? "").isEmpty))
                        FadeInDown(
                          duration: const Duration(milliseconds: 600),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(
                                    0xFF2979FF,
                                  ).withValues(alpha: 0.15),
                                  const Color(
                                    0xFF00FF94,
                                  ).withValues(alpha: 0.15),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(
                                  0xFF2979FF,
                                ).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF2979FF,
                                        ).withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.auto_awesome_rounded,
                                        color: Color(0xFF2979FF),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Complete your profile",
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            "Help others find you by adding a bio and your skills.",
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.6),
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                AppButton(
                                  text: "Edit Profile Now",
                                  onPressed: () => context.push(
                                    AppRoutes.editProfile,
                                    extra: user,
                                  ),
                                  style: AppButtonStyle.primary,
                                  height: 48,
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 8),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Discover People",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (_isLoadingDiscovery)
                        const SizedBox(
                          height: 340,
                          child: Center(
                            child: AppLoadingIndicator(
                              isFullScreen: false,
                              size: 30,
                            ),
                          ),
                        )
                      else if (_randomUsers == null || _randomUsers!.isEmpty)
                        const SizedBox(
                          height: 200,
                          child: Center(
                            child: Text(
                              "No new people to discover",
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                        )
                      else
                        FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          child: ModernPeopleCarousel(users: _randomUsers!),
                        ),

                      const SizedBox(height: 24),

                      const SizedBox(height: 140),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class RecommendedPeopleSection extends StatelessWidget {
  final List<UserModel> users;
  const RecommendedPeopleSection({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthService>().currentUserId;
    if (currentUserId == null) return const SizedBox.shrink();

    return Column(
      children: users.asMap().entries.map((entry) {
        final index = entry.key;
        final user = entry.value;
        return FadeInUp(
          key: ValueKey(user.id),
          delay: Duration(milliseconds: index * 50),
          duration: const Duration(milliseconds: 600),
          child: UserTile(user: user, currentUserId: currentUserId),
        );
      }).toList(),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        borderRadius: 20,
        onTap: () => context.push(AppRoutes.profile, extra: user),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF2979FF), Color(0xFF00FF94)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                padding: const EdgeInsets.all(1.5),
                child: Hero(
                  tag: 'avatar_${user.id}',
                  child: AppAvatar(
                    imageUrl: user.photoURL,
                    customSize: 44,
                    initials: user.username.isNotEmpty ? user.username[0] : '?',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'name_hero_${user.id}',
                    child: Text(
                      user.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.role.isNotEmpty ? user.role.toUpperCase() : "EXPLORER",
                    style: TextStyle(
                      color: const Color(0xFF2979FF),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2979FF).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_add_rounded,
                color: Color(0xFF2979FF),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
