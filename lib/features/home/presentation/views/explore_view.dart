import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';
import 'package:chat_app/core/services/auth_service.dart';
import 'package:chat_app/core/services/firestoreservice.dart';
import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:chat_app/features/home/presentation/widgets/people_grid_card.dart';
import 'package:chat_app/router/route_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:chat_app/core/widgets/common/app_base_view.dart';
import 'package:chat_app/core/widgets/common/skeleton_shimmer.dart';
import 'package:chat_app/core/widgets/common/glass_container.dart';
import 'package:chat_app/core/widgets/common/tactile_feedback.dart';
import 'package:chat_app/core/widgets/common/app_empty_state.dart';
import 'package:chat_app/core/widgets/common/app_loading_indicator.dart';
import 'package:animated_text_kit/animated_text_kit.dart';


class ExploreView extends StatefulWidget {
  const ExploreView({super.key});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  // State for animated search (Restored exactly as requested)
  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Pagination State
  final List<UserModel> _users = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final int _limit = 6; // Limit per page

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetchUsers() async {
    final firestoreService = context.read<FirestoreService>();
    final currentUserId = context.read<AuthService>().currentUserId;

    try {
      final snapshot = await firestoreService.getPaginatedUsers(_limit, lastDocument: _lastDocument);
      
      final List<UserModel> newUsers = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .where((u) => u.id != currentUserId)
          .toList();

      setState(() {
        
        if (_lastDocument == null) {
          _users.clear();
        }
        _users.addAll(newUsers);
        _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
        _isLoading = false;
        _isLoadingMore = false;
        
        // If we got fewer results than limit, there are no more users
        if (snapshot.docs.length < _limit) {
          _hasMore = false;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore && !_isSearchExpanded) {
        setState(() => _isLoadingMore = true);
        _fetchUsers();
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter logic for search
    final List<UserModel> displayedUsers = _isSearchExpanded && _searchController.text.isNotEmpty
        ? _users.where((u) => u.username.toLowerCase().contains(_searchController.text.toLowerCase())).toList()
        : _users;

    return AppBaseView(
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: GlassContainer(
                borderRadius: BorderRadius.circular(30),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                height: 54,
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    // Title (Hidden when search expanded)
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _isSearchExpanded ? 0.0 : 1.0,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: AnimatedTextKit(
                          animatedTexts: [
                            TyperAnimatedText(
                              "Explore People",
                              textStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.0,
                                color: Colors.white,
                              ),
                              speed: const Duration(milliseconds: 100),
                            ),
                          ],
                          totalRepeatCount: 1,
                        ),
                      ),
                    ),
                    
                    // Animated Search Bar
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutBack, 
                      width: _isSearchExpanded ? MediaQuery.of(context).size.width - 72 : 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05))
                      ),
                      child: _isSearchExpanded 
                        ? Stack( 
                            children: [
                              Positioned(
                                left: 16,
                                right: 48,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: TextField(
                                    controller: _searchController,
                                    autofocus: true,
                                    onChanged: (_) => setState(() {}),
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                    decoration: InputDecoration(
                                      hintText: "Search people...", 
                                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)),
                                      border: InputBorder.none,
                                      focusedBorder : InputBorder.none,
                                      enabledBorder : InputBorder.none,
                                      filled : false,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                child: TactileFeedback(
                                  onTap: () {
                                    setState(() {
                                      _isSearchExpanded = false;
                                      _searchController.clear();
                                    });
                                  },
                                  child: SizedBox(
                                    width: 48, height: 48,
                                  child: Icon(Icons.close_rounded, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), size: 22),
                                  ),
                                ),
                              )
                            ],
                          )
                        : TactileFeedback(
                            onTap: () {
                              setState(() {
                                _isSearchExpanded = true;
                              });
                            },
                            child: Container(
                              width: 48, height: 48,
                              decoration: const BoxDecoration(color: Colors.transparent),
                              child: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), size: 22),
                            ),
                          ),
                    )
                  ],
                ),
              ),
              ),
            ),
          ),
          
          if (_isLoading && _users.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, 
                  mainAxisSpacing: 16, 
                  crossAxisSpacing: 16, 
                  childAspectRatio: MediaQuery.of(context).size.width < 380 ? 0.7 : 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const SkeletonShimmer(
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: 32,
                  ),
                  childCount: 6,
                ),
              ),
            )
          else if (displayedUsers.isEmpty)
             SliverFillRemaining(
              child: AppEmptyState(
                icon: Icons.search_off_rounded,
                title: "No results found",
                message: "No users match your current search criteria. Try a different username or explore other people.",
                onAction: _isSearchExpanded ? () {
                  setState(() {
                    _isSearchExpanded = false;
                    _searchController.clear();
                  });
                } : null,
                actionLabel: "Clear Search",
              ),
            )
          else ...[
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, 
                  mainAxisSpacing: 16, 
                  crossAxisSpacing: 16, 
                  childAspectRatio: MediaQuery.of(context).size.width < 380 ? 0.7 : 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final user = displayedUsers[index];
                    return FadeInUp(
                      key: ValueKey(user.id),
                      delay: Duration(milliseconds: (index % _limit) * 50),
                      duration: const Duration(milliseconds: 500),
                      child: PeopleGridCard(
                        user: user,
                        onTap: () {
                             context.push(AppRoutes.profile, extra: user);
                        },
                      ),
                    );
                  },
                  childCount: displayedUsers.length,
                ),
              ),
            ),
            
            if (_hasMore && !_isSearchExpanded)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: _isLoadingMore 
                    ? AppLoadingIndicator(size: 30, isFullScreen: false)
                    : Center(
                        child: TextButton(
                          onPressed: _fetchUsers,
                          child: Text("Load More People", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                        ),
                      ),
                ),
              ),
              
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ],
      ),
    );
  }
}
