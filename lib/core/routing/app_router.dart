import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/pin_details.dart';
import '../../features/home/presentation/pages/profile_page.dart';
import '../../features/home/presentation/pages/search_page.dart';
import '../widgets/main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Watch auth state to trigger router rebuilds
  ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuthenticated = authState.isAuthenticated;
      final isAuthPage = state.matchedLocation == '/auth';
      final isLoading = authState.isLoading;

      // Wait for auth check to complete
      if (isLoading) {
        return null; // Stay on current route while loading
      }

      // Redirect to auth if not authenticated and not already on auth page
      if (!isAuthenticated && !isAuthPage) {
        return '/auth';
      }

      // Redirect to home if authenticated and on auth page
      if (isAuthenticated && isAuthPage) {
        return '/';
      }

      return null; // No redirect needed
    },
    routes: [
      GoRoute(path: '/auth', builder: (context, state) => const AuthPage()),
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomePage()),
          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchPage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: '/pin/:id',
            builder: (context, state) {
              final pinId = state.pathParameters['id'] ?? '';
              final extra = state.extra as Map<String, dynamic>?;
              return PinDetailPage(
                pinId: pinId,
                imageUrl: extra?['imageUrl'] as String? ?? '',
                heroTag: extra?['heroTag'] as String? ?? '',
              );
            },
          ),
        ],
      ),
    ],
  );
});
