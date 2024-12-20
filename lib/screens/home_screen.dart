import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dashboard/dashboard_screen.dart';
import 'clients/client_list_screen.dart';
import 'reports/reports_screen.dart';
import 'settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ClientListScreen(),
    const ReportsScreen(),
    const SettingsScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
        physics: const NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.dashboard_outlined,
                color: _currentIndex == 0 ? AppTheme.brandTeal : AppTheme.inactiveGrey,
              ),
              activeIcon: const Icon(Icons.dashboard, color: AppTheme.brandTeal),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.people_outline,
                color: _currentIndex == 1 ? AppTheme.brandTeal : AppTheme.inactiveGrey,
              ),
              activeIcon: const Icon(Icons.people, color: AppTheme.brandTeal),
              label: 'Clients',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.bar_chart_outlined,
                color: _currentIndex == 2 ? AppTheme.brandTeal : AppTheme.inactiveGrey,
              ),
              activeIcon: const Icon(Icons.bar_chart, color: AppTheme.brandTeal),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.settings_outlined,
                color: _currentIndex == 3 ? AppTheme.brandTeal : AppTheme.inactiveGrey,
              ),
              activeIcon: const Icon(Icons.settings, color: AppTheme.brandTeal),
              label: 'Settings',
            ),
          ],
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
          ),
        ),
      ),
    );
  }
} 