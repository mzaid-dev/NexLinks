import 'package:nexlinks/core/widgets/common/app_loading_indicator.dart';
import 'package:nexlinks/core/services/auth_service.dart';
import 'package:nexlinks/core/services/firestoreservice.dart';
import 'package:nexlinks/features/auth/data/models/user_model.dart';
import 'package:nexlinks/features/profile/presentation/widgets/profile_about.dart';
import 'package:nexlinks/features/profile/presentation/widgets/profile_expertise.dart';
import 'package:nexlinks/features/profile/presentation/widgets/profile_header.dart';
import 'package:nexlinks/features/profile/presentation/widgets/profile_info_section.dart';
import 'package:nexlinks/features/profile/presentation/widgets/profile_stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nexlinks/core/widgets/common/app_base_view.dart';
import 'package:nexlinks/features/auth/logic/auth_bloc.dart';
import 'package:nexlinks/features/auth/logic/auth_event.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

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
          showGlows: false, // Disabled for cleaner look
          child: Scaffold(
            backgroundColor: Colors.transparent, // Let AppBaseView handle the background
            body: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context),
                  const SizedBox(height: 10),
                  if (displayUser != null)
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ProfileHeader(
                              displayUser: displayUser,
                              isMe: widget.isMe,
                              currentUserId: currentUser?.uid,
                            ),
                            const SizedBox(height: 32),
                            ProfileStats(
                              sessions: displayUser.projectsCount,
                              successRate: displayUser.successRate,
                              experienceYears: displayUser.experienceYears,
                            ),
                            const SizedBox(height: 32),
                            ProfileAbout(bio: displayUser.bio),
                            const SizedBox(height: 32),
                            ProfileInfoSection(
                              username: displayUser.username,
                              role: displayUser.role,
                            ),
                            const SizedBox(height: 32),
                            ProfileExpertise(expertise: displayUser.expertise),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
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
            const SizedBox(width: 40), // Spacer to keep title centered
          
          AnimatedTextKit(
            animatedTexts: [
              TyperAnimatedText(
                "Profile",
                textStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
                speed: const Duration(milliseconds: 100),
              ),
            ],
            totalRepeatCount: 1,
          ),
          
          if (widget.isMe)
            _buildIconBtn(
              icon: Icons.logout_rounded,
              iconColor: Colors.redAccent,
              onTap: () {
                 context.read<AuthBloc>().add(AuthLogoutRequested());
              },
            )
          else
            const SizedBox(width: 40), // Spacer to keep title centered
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
