import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: navigationShell,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 12, bottom: 24, left: 8, right: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _CustomNavItem(
              index: 0,
              currentIndex: navigationShell.currentIndex,
              label: 'Home',
              icon: Icons.home_rounded,
              iconColor: Colors.blue,
              onTap: _onTap,
            ),
            _CustomNavItem(
              index: 1,
              currentIndex: navigationShell.currentIndex,
              label: 'Family Hub',
              icon: Icons.people_alt_rounded,
              iconColor: Colors.purpleAccent,
              onTap: _onTap,
            ),
            _CustomNavItem(
              index: 2,
              currentIndex: navigationShell.currentIndex,
              label: 'Maintenance',
              icon: Icons.build_rounded,
              iconColor: Colors.redAccent,
              onTap: _onTap,
            ),
            _CustomNavItem(
              index: 3,
              currentIndex: navigationShell.currentIndex,
              label: 'Digital Vault',
              icon: Icons.account_balance_wallet_rounded,
              iconColor: Colors.orangeAccent,
              onTap: _onTap,
            ),
            _CustomNavItem(
              index: 4,
              currentIndex: navigationShell.currentIndex,
              label: 'Settings',
              icon: Icons.settings_rounded,
              iconColor: Colors.deepPurpleAccent,
              onTap: _onTap,
            ),
          ],
        ),
      ),
    );
  }

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _CustomNavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final String label;
  final IconData icon;
  final Color iconColor;
  final Function(int) onTap;

  const _CustomNavItem({
    required this.index,
    required this.currentIndex,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 48,
            width: 64,
            decoration: isSelected
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        iconColor.withOpacity(0.35),
                        iconColor.withOpacity(0.0),
                      ],
                      stops: const [0.2, 1.0],
                    ),
                  )
                : null,
            child: Icon(
              icon,
              color: isSelected ? iconColor : iconColor.withOpacity(0.8),
              size: 28,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

