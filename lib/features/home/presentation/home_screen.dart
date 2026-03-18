import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../../core/providers/auth_providers.dart';
import '../../family_hub/presentation/providers/family_hub_providers.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _slideAnimations = List.generate(6, (index) {
      final double begin = (0.1 + (index * 0.1)).clamp(0.0, 1.0);
      final double end = (0.6 + (index * 0.1)).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0.0, 0.2),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(begin, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildHeader(),
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildFamilyBar(),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(36),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(36),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(36),
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SlideTransition(
                              position: _slideAnimations[0],
                              child: _buildSectionTitle('Today\'s Highlights'),
                            ),
                            const SizedBox(height: 16),
                            _buildHighlightsGrid(),
                            const SizedBox(height: 32),
                            SlideTransition(
                              position: _slideAnimations[2],
                              child: _buildSectionTitle('Household Highlights'),
                            ),
                            const SizedBox(height: 16),
                            _buildHouseholdHighlights(),
                            const SizedBox(height: 32),
                            SlideTransition(
                              position: _slideAnimations[4],
                              child: _buildSectionTitle(
                                'Family Feed & Memories',
                                onViewAll: () => context.push('/memories'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildFeedSection(),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good Morning,';
    if (hour >= 12 && hour < 20) return 'Hello,';
    return 'Good Night,';
  }

  Widget _buildFamilyBar() {
    final familyMembers = ref.watch(familyMembersProvider).value ?? [];
    final currentUser = ref.watch(userProfileProvider).value;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                if (currentUser != null)
                  _buildAvatarItem(
                    name: currentUser['firstName'] ?? 'Me',
                    imageUrl: currentUser['photoUrl'],
                    isCurrentUser: true,
                  ),
                ...familyMembers.map(
                  (member) => _buildAvatarItem(
                    name: member['name'] ?? member['firstName'] ?? 'Member',
                    imageUrl: member['photoUrl'],
                    isCurrentUser: false,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _showInviteDialog,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: AppColors.primaryBlue,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarItem({
    required String name,
    String? imageUrl,
    bool isCurrentUser = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0, left: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCurrentUser
                        ? AppColors.successGreen
                        : Colors.white,
                    width: 2,
                  ),
                ),
                child: UserAvatar(name: name, imageUrl: imageUrl, radius: 22),
              ),
              if (isCurrentUser)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.successGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showInviteDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Invite Family User',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Add a new member to your Family Hub',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.isEmpty ||
                            emailController.text.isEmpty) {
                          Fluttertoast.showToast(
                            msg: "Please fill all fields",
                            backgroundColor: AppColors.errorRed,
                            textColor: Colors.white,
                          );
                          return;
                        }

                        // Close dialog
                        Navigator.pop(context);

                        // Show loading
                        Fluttertoast.showToast(
                          msg: "Sending invitation...",
                          backgroundColor: AppColors.infoBlue,
                          textColor: Colors.white,
                        );

                        try {
                          await ref
                              .read(authServiceProvider)
                              .inviteFamilyMember(
                                name: nameController.text.trim(),
                                email: emailController.text.trim(),
                              );

                          Fluttertoast.showToast(
                            msg: "Invitation sent successfully!",
                            backgroundColor: AppColors.successGreen,
                            textColor: Colors.white,
                          );
                        } catch (e) {
                          Fluttertoast.showToast(
                            msg: "Failed to send invitation: $e",
                            backgroundColor: AppColors.errorRed,
                            textColor: Colors.white,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Send Invite'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final userProfile = ref.watch(userProfileProvider).value;
    final authUser = ref.watch(authStateProvider).value;

    final firstName =
        userProfile?['firstName'] ??
        authUser?.displayName?.split(' ').first ??
        'User';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            Row(
              children: [
                Text(
                  '$firstName!',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('👋', style: TextStyle(fontSize: 24)),
              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: () => context.push('/profile'),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: UserAvatar(name: firstName, radius: 24),
          ),
        ),
      ],
    );
  }

  Widget _buildHouseholdHighlights() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          _buildQuickAccessCard(
            title: 'Appliances',
            icon: Icons.kitchen_rounded,
            color: Colors.blueAccent,
            onTap: () => context.push('/appliances'),
          ),
          const SizedBox(width: 16),
          _buildQuickAccessCard(
            title: 'Vehicles',
            icon: Icons.directions_car_rounded,
            color: Colors.orangeAccent,
            onTap: () => context.push('/vehicles'),
          ),
          const SizedBox(width: 16),
          _buildQuickAccessCard(
            title: 'Vault',
            icon: Icons.account_balance_wallet_rounded,
            color: Colors.greenAccent,
            onTap: () => context.push('/vault'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: _GlassCard(
        width: 140,
        usePureWhite: true,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View All',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppColors.primaryBlue),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHighlightsGrid() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Column(
            children: [
              SlideTransition(
                position: _slideAnimations[1],
                child: _buildHomeHealthScore(),
              ),
              const SizedBox(height: 16),
              SlideTransition(
                position: _slideAnimations[2],
                child: _buildAlertCard(
                  icon: Icons.ac_unit,
                  iconColor: Colors.blue,
                  bgColor: Colors.blue[50]!.withOpacity(0.5),
                  title: 'AC Service:\n3 days',
                ),
              ),
              const SizedBox(height: 12),
              SlideTransition(
                position: _slideAnimations[3],
                child: _buildAlertCard(
                  icon: Icons.sensors,
                  iconColor: Colors.orange,
                  bgColor: Colors.orange[50]!.withOpacity(0.5),
                  title: 'Smoke Detector:\nCheck Battery',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              SlideTransition(
                position: _slideAnimations[1],
                child: _buildDinnerPoll(),
              ),
              const SizedBox(height: 16),
              SlideTransition(
                position: _slideAnimations[2],
                child: _buildQuickReminders(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHomeHealthScore() {
    return _GlassCard(
      usePureWhite: true,
      child: Column(
        children: [
          const Text(
            'Home Health Score',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.successGreen.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: CircularProgressIndicator(
                  value: 0.82,
                  strokeWidth: 10,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  color: AppColors.successGreen,
                ),
              ),
              const Text(
                '82',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.successGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: const TextSpan(
              text: 'Overall: ',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              children: [
                TextSpan(
                  text: 'Good',
                  style: TextStyle(
                    color: AppColors.successGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDinnerPoll() {
    return GestureDetector(
      onTap: () => context.push('/meals'),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryMint.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'What\'s for dinner tonight?',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'View All',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPollOption('Pizza 🍕', true),
                  const SizedBox(height: 8),
                  _buildPollOption('Spaghetti 🍝', false),
                  const SizedBox(height: 8),
                  _buildPollOption('Chicken & Rice 🍗', false),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPollOption(String text, bool isLeading) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isLeading ? Colors.white : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLeading ? Colors.white : Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
              fontWeight: isLeading ? FontWeight.bold : FontWeight.w600,
              fontSize: 13,
              color: isLeading ? AppColors.textPrimary : Colors.white,
            ),
          ),
          if (isLeading)
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.warningOrange,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickReminders() {
    return _GlassCard(
      usePureWhite: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Reminders',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildReminderItem('Groceries: 3 items'),
          _buildReminderItem('Electricity Bill due'),
          _buildReminderItem('Car Service'),
        ],
      ),
    );
  }

  Widget _buildReminderItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 12),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
  }) {
    return _GlassCard(
      usePureWhite: true,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedSection() {
    return SizedBox(
      height: 250,
      child: SlideTransition(
        position: _slideAnimations[5],
        child: ListView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          physics: const BouncingScrollPhysics(),
          children: [
            _buildMemoryCard(),
            const SizedBox(width: 16),
            _buildUpdateCard(),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoryCard() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        image: const DecorationImage(
          image: NetworkImage('https://picsum.photos/600/400?random=1'),
          fit: BoxFit.cover,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: const Text(
                  '3 Years Ago Today',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Family trip memories',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateCard() {
    return _GlassCard(
      width: 240,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const UserAvatar(name: 'Dad', radius: 14),
              const SizedBox(width: 10),
              const Text(
                'Dad',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              'https://picsum.photos/400/200?random=2',
              height: 80,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'AC service scheduled for tomorrow!',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Icon(
                Icons.favorite_border,
                size: 20,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.chat_bubble_outline,
                size: 20,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final bool usePureWhite;

  const _GlassCard({
    required this.child,
    this.width,
    this.padding,
    this.usePureWhite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: usePureWhite ? Colors.white : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: usePureWhite ? Colors.white : Colors.white.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          if (usePureWhite)
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            )
          else
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              spreadRadius: -5,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
