import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinterest/features/home/data/models/pin_model.dart';
import 'package:pinterest/features/home/domain/entities/pin.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/pin_details.dart';
import '../../features/home/presentation/pages/profile_page.dart';
import '../../features/home/presentation/pages/search_page.dart';
import '../../main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  ref.watch(authProvider);

  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/',
    redirect: (context, state) {
      final auth = ref.read(authProvider);

      final isLoggedIn = auth.isAuthenticated;
      final isLoading = auth.isLoading;
      final isAuthRoute = state.matchedLocation == '/auth';

      if (isLoading) return null;

      // If NOT logged in → send to auth
      if (!isLoggedIn && !isAuthRoute) {
        return '/auth';
      }

      // If logged in → block auth page
      if (isLoggedIn && isAuthRoute) {
        return '/';
      }

      return null;
    },

    routes: [
      GoRoute(path: '/auth', builder: (_, __) => const AuthPage()),

      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => HomePage()),
          GoRoute(path: '/search', builder: (_, __) => SearchPage()),
          GoRoute(path: '/profile', builder: (_, __) => ProfilePage()),

          GoRoute(
            path: '/pin/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              final extra = state.extra as Pin;

              return PinDetailPage(pin: extra);
            },
          ),
        ],
      ),
    ],
  );
});
