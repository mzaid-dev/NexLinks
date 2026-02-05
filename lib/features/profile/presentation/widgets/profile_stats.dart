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
    return Row(
      children: [
        Expanded(
          child: _buildStatPanel(
            context, 
            "PROJECTS", 
            sessions == 0 ? "—" : "$sessions+",
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatPanel(
            context, 
            "SUCCESS", 
            successRate == 0 ? "—" : "$successRate%",
            valueColor: const Color(0xFF00FF94),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatPanel(
            context, 
            "EXP.", 
            experienceYears == 0 ? "—" : "$experienceYears Yrs",
          ),
        ),
      ],
    );
  }

  Widget _buildStatPanel(BuildContext context, String label, String value, {Color? valueColor}) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      borderRadius: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Theme.of(context).colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.0,
            ),
          ),
        ],
      ),
    );
  }
}
