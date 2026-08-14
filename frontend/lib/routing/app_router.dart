import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../design/colors.dart';
import '../core/storage/secure_storage.dart';
import '../features/activity/screens/activity_screen.dart';
import '../features/add/widgets/add_show_sheet.dart';
import '../features/alerts/screens/alerts_screen.dart';
import '../features/auth/screens/onboarding_screen.dart';
import '../features/auth/screens/welcome_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/lists/screens/list_detail_screen.dart';
import '../features/lists/screens/lists_screen.dart';
import '../features/profile/screens/diary_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/stats_screen.dart';
import '../features/profile/screens/up_next_screen.dart';
import '../features/search/screens/search_screen.dart';
import '../features/show/screens/cast_crew_screen.dart';
import '../features/show/screens/cast_graph_screen.dart';
import '../features/show/screens/person_screen.dart';
import '../features/show/screens/recap_screen.dart';
import '../features/show/screens/season_screen.dart';
import '../features/show/screens/show_detail_screen.dart';
import '../shared/widgets/glass_bottom_nav.dart';

// ── Shell scaffold ─────────────────────────────────────────────────────────────

class _ShellScaffold extends StatefulWidget {
  const _ShellScaffold({required this.child, required this.state});
  final Widget child;
  final GoRouterState state;

  @override
  State<_ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends State<_ShellScaffold> {
  NavTab get _currentTab {
    final path = widget.state.matchedLocation;
    if (path.startsWith('/search')) return NavTab.search;
    if (path.startsWith('/activity')) return NavTab.activity;
    if (path.startsWith('/profile')) return NavTab.profile;
    return NavTab.home;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          GlassBottomNav(
            currentTab: _currentTab,
            onTabChanged: (tab) {
              switch (tab) {
                case NavTab.home:
                  context.go('/home');
                case NavTab.search:
                  context.go('/search');
                case NavTab.activity:
                  context.go('/activity');
                case NavTab.profile:
                  context.go('/profile');
              }
            },
            onAddPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                barrierColor: Colors.black.withOpacity(0.6),
                builder: (_) => const AddShowSheet(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Router provider ────────────────────────────────────────────────────────────

final appRouterProvider = Provider<GoRouter>((ref) {
  final storage = ref.watch(secureStorageProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      // Only redirect from the root
      if (state.matchedLocation == '/') {
        final isLoggedIn = await storage.isLoggedIn;
        return isLoggedIn ? '/home' : '/welcome';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const _LoadingScreen(),
      ),
      GoRoute(
        path: '/welcome',
        pageBuilder: (context, state) => _fadePage(
          state: state,
          child: const WelcomeScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => _fadePage(
          state: state,
          child: const OnboardingScreen(),
        ),
      ),

      // Shell for tabbed screens
      ShellRoute(
        builder: (context, state, child) => _ShellScaffold(
          state: state,
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => _fadePage(
              state: state,
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (context, state) => _fadePage(
              state: state,
              child: const SearchScreen(),
            ),
          ),
          GoRoute(
            path: '/activity',
            pageBuilder: (context, state) => _fadePage(
              state: state,
              child: const ActivityScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => _fadePage(
              state: state,
              child: const ProfileScreen(),
            ),
          ),
        ],
      ),

      // Full-screen routes (outside shell)
      GoRoute(
        path: '/show/:id',
        builder: (context, state) => ShowDetailScreen(
          showId: int.parse(state.pathParameters['id']!),
        ),
        routes: [
          GoRoute(
            path: 'season/:seasonNumber',
            builder: (context, state) => SeasonScreen(
              showId: int.parse(state.pathParameters['id']!),
              seasonNumber:
                  int.parse(state.pathParameters['seasonNumber']!),
            ),
          ),
          GoRoute(
            path: 'cast',
            builder: (context, state) => CastCrewScreen(
              showId: int.parse(state.pathParameters['id']!),
            ),
          ),
          GoRoute(
            path: 'recap',
            builder: (context, state) => RecapScreen(
              showId: int.parse(state.pathParameters['id']!),
            ),
          ),
          GoRoute(
            path: 'cast-graph',
            builder: (context, state) => CastGraphScreen(
              showId: int.parse(state.pathParameters['id']!),
            ),
          ),
        ],
      ),

      GoRoute(
        path: '/person/:id',
        builder: (context, state) => PersonScreen(
          personId: int.parse(state.pathParameters['id']!),
        ),
      ),

      GoRoute(
        path: '/lists',
        builder: (context, state) => const ListsScreen(),
        routes: [
          GoRoute(
            path: ':listId',
            builder: (context, state) => ListDetailScreen(
              listId: state.pathParameters['listId']!,
            ),
          ),
        ],
      ),

      GoRoute(
        path: '/alerts',
        builder: (context, state) => const AlertsScreen(),
      ),

      GoRoute(
        path: '/profile/diary',
        builder: (context, state) => const DiaryScreen(),
      ),

      GoRoute(
        path: '/profile/stats',
        builder: (context, state) => const StatsScreen(),
      ),

      GoRoute(
        path: '/profile/up-next',
        builder: (context, state) => const UpNextScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Page not found'),
            TextButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go home'),
            ),
          ],
        ),
      ),
    ),
  );
});

CustomTransitionPage _fadePage({
  required GoRouterState state,
  required Widget child,
}) =>
    CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 180),
    );

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.ink0,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.signal),
      ),
    );
  }
}
