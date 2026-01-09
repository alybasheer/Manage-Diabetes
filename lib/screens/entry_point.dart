import 'package:diabatic/screens/diet_screen.dart';
import 'package:diabatic/screens/glucose_screen.dart';
import 'package:diabatic/screens/home_screen.dart';
import 'package:diabatic/screens/profile_screen.dart';
import 'package:diabatic/utils/theme.dart';
import 'package:flutter/material.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  int _currentIndex = 0;

  final List<Widget> screens = [
    const HomeScreen(),
    const GlucoseScreen(),
    const DietScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.cardWhite,
            AppTheme.cardOffWhite,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
            spreadRadius: 1,
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              index: 0,
              onTap: () {
                setState(() => _currentIndex = 0);
              },
            ),
            _buildNavItem(
              icon: Icons.speed,
              label: 'Glucose',
              index: 1,
              onTap: () {
                setState(() => _currentIndex = 1);
                
              },
            ),
            _buildNavItem(
              icon: Icons.restaurant_rounded,
              label: 'Diet',
              index: 2,
              onTap: () {
                setState(() => _currentIndex = 2);
              
              },
            ),
            _buildNavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              index: 3,
              onTap: () {
                setState(() => _currentIndex = 3);
              
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required VoidCallback onTap,
  }) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.primary.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 28,
              color: isActive ? AppTheme.primary : AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? AppTheme.primary : AppTheme.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
