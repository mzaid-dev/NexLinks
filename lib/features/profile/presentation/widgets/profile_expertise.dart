import 'package:nexlinks/features/home/presentation/widgets/glass_card.dart';
import 'package:flutter/material.dart';

class ProfileExpertise extends StatelessWidget {
  final List<String> expertise;

  const ProfileExpertise({super.key, required this.expertise});

  @override
  Widget build(BuildContext context) {
    if (expertise.isEmpty) return const SizedBox.shrink();

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Expertise",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: expertise.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF2979FF).withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2979FF).withValues(alpha: 0.1),
                    blurRadius: 8
                  )
                ]
              ),
              child: Text(tag, style: const TextStyle(color: Color(0xFF2979FF), fontWeight: FontWeight.w600)),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
