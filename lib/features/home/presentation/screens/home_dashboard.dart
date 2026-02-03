import 'package:nexlinks/core/services/auth_service.dart';
import 'package:nexlinks/features/chat/data/chat_service.dart';
import 'package:nexlinks/features/profile/presentation/screens/profile_screen.dart';
import 'package:nexlinks/features/home/presentation/widgets/custom_bottom_nav.dart';
// TODO: Enable in second update
// import 'package:nexlinks/features/home/presentation/widgets/notification_wrapper.dart';
import 'package:nexlinks/features/home/presentation/views/home_view.dart';
import 'package:nexlinks/features/home/presentation/views/explore_view.dart';
import 'package:nexlinks/features/home/presentation/views/chat_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexlinks/features/home/logic/home_navigation_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  List<Widget> get _pages => [
    const HomeView(),
    const ExploreView(),
    const ChatListView(),
    const ProfileScreen(isMe: true),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeNavigationCubit(),
      child: Builder(
        builder: (context) {
          final selectedIndex = context.select((HomeNavigationCubit cubit) => cubit.state);
          
          return Scaffold(
              extendBody: true, // Allows body to scroll behind Nav Bar
              backgroundColor: const Color(0xFF000000), 
              body: Stack(
                children: [
                  // 1. Background (glows disabled for cleaner look)
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF050505),
                    ),
                  ),

                  // 2. Main Content
                  SafeArea(
                    bottom: false,
                    child: Padding(
                       padding: const EdgeInsets.only(bottom: 0), // Removed bottom padding so it goes behind nav
                       child: AnimatedSwitcher(
                         duration: const Duration(milliseconds: 300), 
                         switchInCurve: Curves.easeOut,
                         switchOutCurve: Curves.easeIn,
                         transitionBuilder: (Widget child, Animation<double> animation) {
                           return FadeTransition(
                             opacity: animation,
                             child: child, 
                           );
                         },
                         child: KeyedSubtree(
                           key: ValueKey<int>(selectedIndex),
                           child: _pages[selectedIndex],
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
                     selectedIndex: selectedIndex,
                     onItemSelected: (index) {
                       context.read<HomeNavigationCubit>().changeTab(index);
                     },
                     unreadChatCount: unreadCount,
                   );
                }
                ),
          );
        }
      ),
    );
  }
}
