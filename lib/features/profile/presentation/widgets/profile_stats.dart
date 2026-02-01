import 'package:nexlinks/features/home/presentation/widgets/glass_card.dart';
import 'package:flutter/material.dart';

class ProfileStats extends StatelessWidget {
  final int sessions;
  final int successRate;
  final int experienceYears;

  const ProfileStats({
    super.key,
    required this.sessions,
    required this.successRate,
    required this.experienceYears,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(context, "SESSIONS", "$sessions+"),
          Container(height: 40, width: 1, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
          _buildStatItem(context, "SUCCESS", "$successRate%"),
           Container(height: 40, width: 1, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
          _buildStatItem(context, "EXPERIENCE", "$experienceYears Years"),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 10,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
