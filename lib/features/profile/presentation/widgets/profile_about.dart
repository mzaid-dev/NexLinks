import 'package:chat_app/features/home/presentation/widgets/glass_card.dart';
import 'package:flutter/material.dart';

class ProfileAbout extends StatelessWidget {
  final String? bio;

  const ProfileAbout({super.key, this.bio});

  @override
  Widget build(BuildContext context) {
    if (bio == null || bio!.isEmpty) return const SizedBox.shrink();

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("About",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            bio!,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 14,
                height: 1.5),
          ),
        ],
      ),
    );
  }
}
