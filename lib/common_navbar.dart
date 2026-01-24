import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'core/constants/app_colors.dart';

class CommonNavbar extends StatelessWidget {
  final int currentIndex;

  const CommonNavbar({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    debugPrint("NAVBAR CLICKED → index: $index");

    if (index == currentIndex) {
      debugPrint("Already on same page, skipping navigation");
      return;
    }

    final router = GoRouter.of(context);

    switch (index) {
      case 0:
        debugPrint("Navigating → HOME");
        router.go('/');
        break;

      case 1:
        debugPrint("Navigating → SEARCH");
        router.go('/search');
        break;

      case 2:
        debugPrint("Opening → CREATE Bottom Sheet");
        _showCreateBottomSheet(context);
        break;

      case 3:
        debugPrint("Messages clicked → NOT IMPLEMENTED YET");
        router.go('/messages');

        break;

      case 4:
        debugPrint("Navigating → PROFILE");
        router.go('/profile');
        break;
    }
  }

  void _showCreateBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button and title
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white, size: 32),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const Spacer(),
                const Text(
                  'Start creating now',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 28), // Balance the close button
              ],
            ),
            const SizedBox(height: 28),

            // Three circular options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCircularOption(
                  context,
                  icon: HugeIcons.strokeRoundedPin02,
                  label: 'Pin',
                  onTap: () {
                    Navigator.pop(context);
                    // Handle create pin
                  },
                ),
                _buildCircularOption(
                  context,
                  icon: HugeIcons.strokeRoundedImage03,
                  label: 'Collage',
                  onTap: () {
                    Navigator.pop(context);
                    // Handle create collage
                  },
                ),
                _buildCircularOption(
                  context,
                  icon: HugeIcons.strokeRoundedGrid,
                  label: 'Board',
                  onTap: () {
                    Navigator.pop(context);
                    // Handle create board
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularOption(
    BuildContext context, {
    required dynamic icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF4A4A4A),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(16),
            child: HugeIcon(icon: icon, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceVariant,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onItemTapped(context, index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        backgroundColor: AppColors.surface,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedHome01,
              color: Colors.white,
            ),
            activeIcon: HugeIcon(
              icon: HugeIcons.strokeRoundedHome01,
              color: Colors.white,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedSearch01,
              color: Colors.white,
            ),
            activeIcon: HugeIcon(
              icon: HugeIcons.strokeRoundedSearch01,
              color: Colors.white,
              strokeWidth: 4.0,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedAdd01,
              color: Colors.white,
            ),
            activeIcon: HugeIcon(
              icon: HugeIcons.strokeRoundedAdd01,
              color: Colors.white,
              strokeWidth: 4.0,
            ),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedMessage02,
              color: Colors.white,
            ),
            activeIcon: HugeIcon(
              icon: HugeIcons.strokeRoundedMessage02,
              color: Colors.white,
              strokeWidth: 4.0,
            ),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedUser,
              color: Colors.white,
            ),
            activeIcon: HugeIcon(
              icon: HugeIcons.strokeRoundedUser,
              color: Colors.white,
              strokeWidth: 4.0,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
