import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'common_navbar.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _getCurrentIndex(String location) {
    if (location == '/') return 0;
    if (location == '/search') return 1;
    if (location == '/profile') return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _getCurrentIndex(location);

    // Don't show navbar on pin detail page
    final showNavbar = !location.startsWith('/pin');

    return Scaffold(
      body: child,
      bottomNavigationBar: showNavbar
          ? CommonNavbar(currentIndex: currentIndex)
          : null,
    );
  }
}
