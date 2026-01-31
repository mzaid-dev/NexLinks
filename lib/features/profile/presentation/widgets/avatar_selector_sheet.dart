import 'package:chat_app/core/widgets/common/glass_container.dart';
import 'package:chat_app/core/widgets/common/tactile_feedback.dart';
import 'package:flutter/material.dart';

class AvatarSelectorSheet extends StatelessWidget {
  const AvatarSelectorSheet({super.key});

  static const List<String> avatars = [
    // Curated high-fidelity avatars (DiceBear styles)
    'https://api.dicebear.com/7.x/notionists/png?seed=Felix',
    'https://api.dicebear.com/7.x/notionists/png?seed=Aneka',
    'https://api.dicebear.com/7.x/notionists/png?seed=Charlie',
    'https://api.dicebear.com/7.x/notionists/png?seed=Liam',
    'https://api.dicebear.com/7.x/notionists/png?seed=Mimi',
    'https://api.dicebear.com/7.x/notionists/png?seed=Toby',
    'https://api.dicebear.com/7.x/notionists/png?seed=Jack',
    'https://api.dicebear.com/7.x/notionists/png?seed=Sasha',
    'https://api.dicebear.com/7.x/personas/png?seed=Leo',
    'https://api.dicebear.com/7.x/personas/png?seed=Zoey',
    'https://api.dicebear.com/7.x/personas/png?seed=Max',
    'https://api.dicebear.com/7.x/personas/png?seed=Ava',
    
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return GlassContainer(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      opacity: 0.1,
      blur: 30,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SizedBox(
        height: screenHeight * 0.6, // Bound to ~60% of screen
        child: Column(
          children: [
            // Handle
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
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Slightly larger for better tap targets
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 24,
                ),
                itemCount: avatars.length,
                itemBuilder: (context, index) {
                  final avatarUrl = avatars[index];
                  return TactileFeedback(
                    onTap: () => Navigator.pop(context, avatarUrl),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white10, width: 2),
                        color: Colors.white.withValues(alpha: 0.05),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          avatarUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
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
