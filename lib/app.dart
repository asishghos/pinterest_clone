import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinterest/features/home/presentation/pages/pin_details.dart';
import 'package:pinterest/features/home/presentation/pages/profile_page.dart';
import 'package:pinterest/features/home/presentation/pages/search_page.dart';
import 'core/constants/app_colors.dart';
import 'features/home/presentation/pages/home_page.dart';

class PinterestApp extends StatelessWidget {
  const PinterestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pinterest Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(path: '/search', builder: (context, state) => const SearchPage()),
    GoRoute(
      path: '/pin/:id',
      builder: (context, state) {
        final pinId = state.pathParameters['id']!;
        final extra = state.extra as Map<String, dynamic>?;
        return PinDetailPage(
          pinId: pinId,
          imageUrl: extra?['imageUrl'] as String,
          heroTag: extra?['heroTag'] as String,
        );
      },
    ),
    GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
  ],
);
