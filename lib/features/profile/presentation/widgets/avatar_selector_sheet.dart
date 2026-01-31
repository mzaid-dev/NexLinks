import 'package:chat_app/core/services/firestoreservice.dart';
import 'package:chat_app/core/widgets/common/glass_container.dart';
import 'package:chat_app/core/widgets/common/tactile_feedback.dart';
import 'package:chat_app/core/widgets/common/app_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AvatarSelectorSheet extends StatelessWidget {
  const AvatarSelectorSheet({super.key});

  static const List<String> avatars = [
    // Curated high-fidelity avatars (DiceBear styles)
    // 'https://api.dicebear.com/7.x/notionists/png?seed=Felix',
    // 'https://api.dicebear.com/7.x/notionists/png?seed=Aneka',
    // 'https://api.dicebear.com/7.x/notionists/png?seed=Charlie',
    // 'https://api.dicebear.com/7.x/notionists/png?seed=Liam',
    // 'https://api.dicebear.com/7.x/notionists/png?seed=Mimi',
    // 'https://api.dicebear.com/7.x/notionists/png?seed=Toby',
    // 'https://api.dicebear.com/7.x/notionists/png?seed=Jack',
    // 'https://api.dicebear.com/7.x/notionists/png?seed=Sasha',
    // 'https://api.dicebear.com/7.x/personas/png?seed=Leo',
    // 'https://api.dicebear.com/7.x/personas/png?seed=Zoey',
    // 'https://api.dicebear.com/7.x/personas/png?seed=Max',
    // 'https://api.dicebear.com/7.x/personas/png?seed=Ava',
    // 'https://api.dicebear.com/9.x/micah/svg?seed=Aidan',
    // 'https://api.dicebear.com/9.x/notionists/svg?seed=Jocelyn',
    // 'https://api.dicebear.com/9.x/notionists-neutral/svg?seed=Sarah',
    // 'https://api.dicebear.com/9.x/thumbs/svg?seed=Nolan',
    // 'https://api.dicebear.com/9.x/toon-head/svg?seed=Jessica',
    // 'https://api.dicebear.com/7.x/toon-head/png?seed=Kimberly',
    // 'https://api.dicebear.com/7.x/notionists/png?seed=Felix'
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
                    itemCount: allAvatars.length,
                    itemBuilder: (context, index) {
                      final avatarUrl = allAvatars[index];
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
