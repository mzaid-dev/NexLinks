import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PeopleGridShimmer extends StatelessWidget {
  const PeopleGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.05),
      highlightColor: Colors.white.withOpacity(0.1),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.05),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar Skeleton
            const CircleAvatar(radius: 40, backgroundColor: Colors.white),
            const SizedBox(height: 16),
            // Name Skeleton
            Container(width: 80, height: 12, decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: Colors.white)),
            const SizedBox(height: 8),
            // Role Skeleton
            Container(width: 120, height: 10, decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: Colors.white)),
            const Spacer(),
            // Button Skeleton
            Container(width: double.infinity, height: 32, decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
