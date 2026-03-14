import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/animated_gradient_background.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../widgets/help_center_dialog.dart';
import '../widgets/about_app_dialog.dart';
import '../widgets/contact_us_dialog.dart';
import '../widgets/how_to_use_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Settings',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          centerTitle: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: const UserAvatar(name: 'Sarah', radius: 18),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModernCard(
                context,
                title: 'Appliances',
                subtitle: 'Track warranty & service',
                icon: Icons.kitchen_rounded,
                color: Colors.blueAccent,
                route: '/appliances',
              ),
              const SizedBox(height: 20),
              _buildModernCard(
                context,
                title: 'Vehicles',
                subtitle: 'Manage service schedules',
                icon: Icons.directions_car_rounded,
                color: Colors.orangeAccent,
                route: '/vehicles',
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildSmallCard(
                      context,
                      title: 'Subscriptions',
                      icon: Icons.sync_rounded,
                      color: Colors.purpleAccent,
                      route: '/subscriptions',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSmallCard(
                      context,
                      title: 'Utilities',
                      icon: Icons.power_rounded,
                      color: Colors.greenAccent,
                      route: '/utilities',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildModernCard(
                context,
                title: 'Emergency Contacts',
                subtitle: 'Quick access when needed',
                icon: Icons.emergency_rounded,
                color: Colors.redAccent,
                route: '/emergency',
              ),
              const SizedBox(height: 30),
              const Text(
                'App Settings',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      Icons.help_rounded,
                      'Help & Support',
                      Colors.blueGrey,
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => const HelpCenterDialog(),
                      ),
                    ),
                    _buildSettingsTile(
                      Icons.info_outline_rounded,
                      'About App',
                      Colors.teal,
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => const AboutAppDialog(),
                      ),
                    ),
                    _buildSettingsTile(
                      Icons.email_outlined,
                      'Contact Us',
                      Colors.pink,
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => const ContactUsDialog(),
                      ),
                    ),
                    _buildSettingsTile(
                      Icons.menu_book_outlined,
                      'How to Use',
                      Colors.purple,
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => const HowToUseDialog(),
                      ),
                    ),
                    _buildSettingsTile(
                      Icons.logout_rounded,
                      'Logout',
                      Colors.redAccent,
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100), // Space for bottom bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: _getPastelColor(title),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(icon, size: 28, color: color),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Colors.grey.shade900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.textHint.withOpacity(0.4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: _getPastelColor(title),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, size: 24, color: color),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    Color iconColor, {
    bool showDivider = true,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          title: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: AppColors.textHint,
          ),
          onTap: onTap,
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 56),
            child: Divider(
              color: AppColors.textHint.withOpacity(0.1),
              height: 1,
            ),
          ),
      ],
    );
  }

  Color _getPastelColor(String title) {
    switch (title) {
      case 'Appliances':
        return Colors.blue.shade50;
      case 'Vehicles':
        return Colors.orange.shade50;
      case 'Subscriptions':
        return Colors.purple.shade50;
      case 'Utilities':
        return Colors.green.shade50;
      case 'Emergency Contacts':
        return Colors.red.shade50;
      default:
        return Colors.white;
    }
  }
}
