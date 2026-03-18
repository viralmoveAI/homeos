import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../features/family_hub/presentation/widgets/chat_groups_sheet.dart';
import '../../features/vault/presentation/widgets/add_document_bottom_sheet.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: navigationShell,
      floatingActionButton: _buildContextualFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 12, bottom: 24, left: 8, right: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -8),
              spreadRadius: 2,
            ),
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

  Widget? _buildContextualFAB(BuildContext context) {
    if (navigationShell.currentIndex == 0) {
      // AI Assistant FAB for Home
      return Padding(
        padding: const EdgeInsets.only(bottom: 84.0),
        child: Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.accentPurple, Color(0xFF7B52FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentPurple.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: 1,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => context.push('/ai-assistant'),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
      );
    } else if (navigationShell.currentIndex == 1) {
      // Family Hub FAB
      return Padding(
        padding: const EdgeInsets.only(bottom: 84.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF25D366), Color(0xFF128C7E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF25D366).withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton(
            backgroundColor: Colors.transparent,
            elevation: 0,
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useRootNavigator: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const ChatGroupsSheet(),
            ),
            child: Icon(Icons.chat, color: Colors.white),
          ),
        ),
      );
    } else if (navigationShell.currentIndex == 3) {
      // Digital Vault FAB
      return Padding(
        padding: const EdgeInsets.only(bottom: 84.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryBlue, Color(0xFF4A80FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.5),
                blurRadius: 25,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.transparent,
            elevation: 0,
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useRootNavigator: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const AddDocumentBottomSheet(),
            ),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text(
              'Add Document',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }
    return null;
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
