import 'dart:ui';
import 'package:flutter/material.dart';


class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final int unreadChatCount;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.unreadChatCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;

    return Container(
      margin: EdgeInsets.only(
        bottom: isSmallScreen ? 16 : 24, 
        left: isSmallScreen ? 12 : 16, 
        right: isSmallScreen ? 12 : 16
      ),
      height: isSmallScreen ? 70 : 80,
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(52),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color!.withOpacity(0.7),
              borderRadius: BorderRadius.circular(52),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white.withOpacity(0.05)
                    : Colors.white.withOpacity(0.4),
                width: 1.5,
              ),
               boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withOpacity(0.5)
                        : const Color(0xFFA3B1C6).withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  )
               ]
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: "Home",
                  isSelected: selectedIndex == 0,
                  onTap: () => onItemSelected(0),
                ),
                _NavItem(
                  icon: Icons.compass_calibration_rounded,
                  label: "Explore",
                  isSelected: selectedIndex == 1,
                  onTap: () => onItemSelected(1),
                ),
                _NavItem(
                  icon: Icons.chat_bubble_rounded,
                  label: "Chat",
                  isSelected: selectedIndex == 2,
                  onTap: () => onItemSelected(2),
                  badgeCount: selectedIndex == 2 ? 0 : unreadChatCount,
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: "Profile",
                  isSelected: selectedIndex == 3,
                  onTap: () => onItemSelected(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int badgeCount;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width < 380 ? 12 : 20, 
          vertical: 12
        ),
        decoration: isSelected
            ? BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFF2E8AF6).withOpacity(0.3))
              )
            : const BoxDecoration(
                color: Colors.transparent,
              ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 1.0, end: isSelected ? 1.0 : 1.0),
              duration: const Duration(milliseconds: 300),
              builder: (context, scale, child) {
                 return Stack(
                   clipBehavior: Clip.none,
                   children: [
                     Icon(
                       icon,
                       color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                       size: 24,
                     ),
                     if (badgeCount > 0)
                       Positioned(
                         top: -2,
                         right: -2,
                         child: Container(
                           padding: const EdgeInsets.all(4),
                           decoration: const BoxDecoration(
                             color: Color(0xFFFF3B30),
                             shape: BoxShape.circle,
                           ),
                           constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                         ),
                       )
                   ],
                 );
              }
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: ClipRect(
                child: SizedBox(
                  width: isSelected ? null : 0,
                  child: Padding(
                    padding: isSelected ? const EdgeInsets.only(left: 8) : EdgeInsets.zero,
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF2E8AF6),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.clip,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
