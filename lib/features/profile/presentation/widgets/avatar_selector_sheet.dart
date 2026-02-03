import 'package:nexlinks/core/services/firestoreservice.dart';
import 'package:nexlinks/core/widgets/common/glass_container.dart';
import 'package:nexlinks/core/widgets/common/tactile_feedback.dart';
import 'package:nexlinks/core/widgets/common/app_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AvatarSelectorSheet extends StatelessWidget {
  const AvatarSelectorSheet({super.key});

  static const List<String> avatars = [
    'https://api.dicebear.com/7.x/notionists/svg?seed=Felix',
    'https://api.dicebear.com/7.x/notionists/svg?seed=Aneka',
    'https://api.dicebear.com/7.x/notionists/svg?seed=Charlie',
    'https://api.dicebear.com/7.x/notionists/svg?seed=Liam',
    'https://api.dicebear.com/7.x/notionists/svg?seed=Mimi',
    'https://api.dicebear.com/7.x/notionists/svg?seed=Toby',
    'https://api.dicebear.com/7.x/personas/svg?seed=Leo',
    'https://api.dicebear.com/7.x/personas/svg?seed=Zoey',
    'https://api.dicebear.com/7.x/personas/svg?seed=Max',
    'https://api.dicebear.com/7.x/personas/svg?seed=Ava',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=Jack',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=Sasha',
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final firestoreService = context.read<FirestoreService>();
    
    return GlassContainer(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      opacity: 0.1,
      blur: 30,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SizedBox(
        height: screenHeight * 0.6,
        child: Column(
          children: [
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Select Your Avatar",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "Choose a persona that represents you best",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: StreamBuilder<List<String>>(
                stream: firestoreService.getAvatars(),
                builder: (context, snapshot) {
                  final dynamicAvatars = snapshot.data ?? [];
                  // Combine dynamic and static, ensuring no duplicates
                  final allAvatars = {...dynamicAvatars, ...avatars}.toList();
                  
                  if (snapshot.connectionState == ConnectionState.waiting && dynamicAvatars.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 24,
                    ),
                    itemCount: allAvatars.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return TactileFeedback(
                          onTap: () => Navigator.pop(context, ""),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_off_outlined, color: Colors.white.withValues(alpha: 0.6)),
                                const SizedBox(height: 4),
                                Text("Default", style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        );
                      }
                      final avatarUrl = allAvatars[index - 1];
                      return TactileFeedback(
                        onTap: () => Navigator.pop(context, avatarUrl),
                        child: AppAvatar(
                          imageUrl: avatarUrl,
                          customSize: 80,
                          showBorder: true,
                          borderColor: Colors.white10,
                          initials: "?",
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
