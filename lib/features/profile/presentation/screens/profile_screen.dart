import 'package:nexlinks/core/widgets/common/app_loading_indicator.dart';
import 'package:nexlinks/core/services/auth_service.dart';
import 'package:nexlinks/core/services/firestoreservice.dart';
import 'package:nexlinks/features/auth/data/models/user_model.dart';
import 'package:nexlinks/features/profile/presentation/widgets/profile_about.dart';
import 'package:nexlinks/features/profile/presentation/widgets/profile_expertise.dart';
import 'package:nexlinks/features/profile/presentation/widgets/profile_info_section.dart';
import 'package:nexlinks/features/profile/presentation/widgets/profile_stats.dart';
import 'package:flutter/material.dart';
import 'package:nexlinks/features/auth/logic/auth_bloc.dart';
import 'package:nexlinks/features/auth/logic/auth_event.dart';
import 'package:nexlinks/features/profile/presentation/widgets/profile_sliver_header.dart';
import 'package:animate_do/animate_do.dart';
import 'package:nexlinks/router/route_names.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nexlinks/core/widgets/common/app_base_view.dart';
import 'package:nexlinks/core/widgets/common/app_button.dart';
import 'package:nexlinks/features/home/presentation/widgets/profile_connect_button.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel? user;
  final bool isMe;

  const ProfileScreen({
    super.key,
    this.user,
    this.isMe = false,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();

    String? targetUserId = widget.isMe ? authService.currentUserId : widget.user?.id;
    if (targetUserId == null) {
      return const Scaffold(body: AppLoadingIndicator());
    }

    return StreamBuilder<UserModel>(
      stream: firestoreService.getUserStream(targetUserId),
      initialData: widget.user,
      builder: (context, snapshot) {
        final displayUser = snapshot.data;
        final currentUser = authService.currentUser;

        return AppBaseView(
          isLoading: snapshot.connectionState == ConnectionState.waiting && displayUser == null,
          error: snapshot.hasError ? snapshot.error : null,
          showGlows: false,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                if (displayUser != null)
                  CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // 1. Animated Slivers Header
                      SliverPersistentHeader(
                        delegate: ProfileSliverHeader(
                          user: displayUser,
                          expandedHeight: 280,
                          topPadding: MediaQuery.of(context).padding.top,
                        ),
                        pinned: true,
                      ),
                      
                      // 2. Action buttons removed from scroll (now fixed at bottom)

                      // 3. Information Sections
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            ProfileStats(
                              sessions: displayUser.projectsCount,
                              successRate: displayUser.successRate,
                              experienceYears: displayUser.experienceYears,
                            ),
                            const SizedBox(height: 24),
                            ProfileInfoSection(
                              username: displayUser.username,
                              role: displayUser.role,
                            ),
                            const SizedBox(height: 24),
                            ProfileAbout(bio: displayUser.bio),
                            const SizedBox(height: 24),
                            ProfileExpertise(expertise: displayUser.expertise),
                            const SizedBox(height: 120), // Increased for fixed button
                          ]),
                        ),
                      ),
                    ],
                  ),
                
                // 4. Overlaid Buttons (Back and Logout)
                _buildFloatingAppBar(context, currentUser),

                // 5. Fixed Action Button at Bottom
                if (displayUser != null)
                  _buildFixedBottomSection(context, displayUser, currentUser?.uid),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFixedBottomSection(BuildContext context, UserModel displayUser, String? currentUserId) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).padding.bottom + 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.0),
              Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.8),
              Theme.of(context).scaffoldBackgroundColor,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: _buildActionButtons(context, displayUser, currentUserId),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, UserModel displayUser, String? currentUserId) {
    if (widget.isMe) {
      return FadeInUp(
        duration: const Duration(milliseconds: 300),
        child: AppButton(
          text: "Edit Profile",
          onPressed: () => context.push(AppRoutes.editProfile, extra: displayUser),
          style: AppButtonStyle.primary,
          height: 52,
          borderRadius: 20,
        ),
      );
    } else if (currentUserId != null) {
      return ProfileConnectButton(
        currentUserId: currentUserId,
        viewedUserId: displayUser.id,
        viewedUser: displayUser,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildFloatingAppBar(BuildContext context, dynamic currentUser) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!widget.isMe)
            _buildIconBtn(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () {
                if (Navigator.canPop(context)) {
                  context.pop();
                }
              },
            )
          else
            const SizedBox(width: 44),
            
          if (widget.isMe)
            _buildIconBtn(
              icon: Icons.logout_rounded,
              iconColor: Colors.redAccent,
              onTap: () {
                 context.read<AuthBloc>().add(AuthLogoutRequested());
              },
            ),
        ],
      ),
    );
  }

  Widget _buildIconBtn({required IconData icon, required VoidCallback onTap, Color? iconColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, color: iconColor ?? Theme.of(context).colorScheme.onSurface, size: 20),
      ),
    );
  }
}
