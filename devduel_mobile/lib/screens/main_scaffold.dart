import 'package:flutter/material.dart';
import '../theme.dart';
import 'home_screen.dart';
import 'battle_screen.dart';
import 'problems_screen.dart';
import 'leaderboard_screen.dart';
import 'profile_screen.dart';


class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  static void setTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_MainScaffoldState>();
    state?._onItemTapped(index);
  }

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_selectedIndex != 0) {
          _onItemTapped(0);
        } else {
          // We are already home, maybe show a "Exit app?" snackbar?
          // For now, just do nothing to prevent the crash
          debugPrint('Back pressed at home - ignoring to prevent crash');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,

        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          physics: const NeverScrollableScrollPhysics(), // Only navigate via BottomNavBar
          children: const [
            HomeScreen(),
            BattleScreen(),
            ProblemsScreen(),
            LeaderboardScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: Container(
          height: 80,
          decoration: const BoxDecoration(
            color: AppColors.background,
            border: Border(top: BorderSide(color: AppColors.zinc800, width: 1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home, 'Home'),
              _buildNavItem(1, Icons.sports_esports, 'Battle'),
              _buildNavItem(2, Icons.terminal, 'Problems'),
              _buildNavItem(3, Icons.leaderboard, 'Leaderboard'),
              _buildNavItem(4, Icons.person, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              color: isSelected ? AppColors.secondary : AppColors.zinc700,
              size: 26,
            ),
          ),
          Text(
            label.toUpperCase(),
            style: AppTheme.labelCaps.copyWith(
              fontSize: 8,
              color: isSelected ? AppColors.secondary : AppColors.zinc700,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
