import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'common_navbar.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _getCurrentIndex(String location) {
    debugPrint("CURRENT ROUTE → $location");

    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/profile')) return 4;
    if (location.startsWith('/messages')) return 3;

    return 0; // Home default
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _getCurrentIndex(location);

    final showNavbar = !location.startsWith('/pin');

    return Scaffold(
      body: child,
      bottomNavigationBar: showNavbar
          ? CommonNavbar(currentIndex: currentIndex)
          : null,
    );
  }
}
