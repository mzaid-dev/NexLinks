import 'package:chat_app/core/services/auth_service.dart';
import 'package:chat_app/features/chat/data/chat_service.dart';
import 'package:chat_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:chat_app/features/home/presentation/widgets/custom_bottom_nav.dart';
import 'package:chat_app/features/home/presentation/widgets/notification_wrapper.dart';
import 'package:chat_app/features/home/presentation/views/home_view.dart';
import 'package:chat_app/features/home/presentation/views/explore_view.dart';
import 'package:chat_app/features/home/presentation/views/chat_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<Widget> get _pages => [
    const HomeView(),
    const ExploreView(),
    const ChatListView(),
    const ProfileScreen(isMe: true),
  ];

  @override
  Widget build(BuildContext context) {
    return NotificationWrapper(
      child: Scaffold(
        extendBody: true, // Allows body to scroll behind Nav Bar
        backgroundColor: const Color(0xFF000000), 
        body: Stack(
          children: [
            // 1. Background with Light Leaks
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF050505),
              ),
            ),
            Positioned(
              top: -100, left: -100,
              child: Container(
                width: 400, height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [const Color(0xFF2E8AF6).withValues(alpha: 0.15), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -100, right: -100,
              child: Container(
                width: 400, height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [const Color(0xFF00F0FF).withValues(alpha: 0.1), Colors.transparent],
                  ),
                ),
              ),
            ),
  
            // 2. Main Content
            SafeArea(
              bottom: false,
              child: Padding(
                 padding: const EdgeInsets.only(bottom: 0), // Removed bottom padding so it goes behind nav
                 child: AnimatedSwitcher(
                   duration: const Duration(milliseconds: 300), // Reduced slightly for snappier feel
                   switchInCurve: Curves.easeOut,
                   switchOutCurve: Curves.easeIn,
                   transitionBuilder: (Widget child, Animation<double> animation) {
                     // FIX: Removed SlideTransition. 
                     // Only use FadeTransition so inner animations (FadeInDown) don't glitch.
                     return FadeTransition(
                       opacity: animation,
                       child: child, 
                     );
                   },
                   child: KeyedSubtree(
                     key: ValueKey<int>(_selectedIndex),
                     child: _pages[_selectedIndex],
                   ),
                 ),
              )
            ),
          ],
        ),
        bottomNavigationBar: StreamBuilder<int>(
          stream: ChatService().getGlobalUnreadCountStream(context.read<AuthService>().currentUserId ?? ''),
          builder: (context, snapshot) {
            final unreadCount = snapshot.data ?? 0;
            return CustomBottomNavBar(
               selectedIndex: _selectedIndex,
               onItemSelected: (index) {
                 setState(() => _selectedIndex = index);
               },
               unreadChatCount: unreadCount,
             );
          }
        ),
      ),
    );
  }
}
