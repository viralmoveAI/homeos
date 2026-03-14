import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/animated_gradient_background.dart';

class InviteFamilyScreen extends StatefulWidget {
  const InviteFamilyScreen({super.key});

  @override
  State<InviteFamilyScreen> createState() => _InviteFamilyScreenState();
}

class _InviteFamilyScreenState extends State<InviteFamilyScreen> with SingleTickerProviderStateMixin {
  final List<Map<String, TextEditingController>> _members = [
    {
      'name': TextEditingController(),
      'email': TextEditingController(),
    }
  ];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
       vsync: this, 
       duration: const Duration(milliseconds: 1000)
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic)),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var member in _members) {
      member['name']?.dispose();
      member['email']?.dispose();
    }
    super.dispose();
  }

  void _addMember() {
    setState(() {
      _members.add({
        'name': TextEditingController(),
        'email': TextEditingController(),
      });
    });
  }

  void _removeMember(int index) {
    if (_members.length > 1) {
      setState(() {
        _members[index]['name']?.dispose();
        _members[index]['email']?.dispose();
        _members.removeAt(index);
      });
    }
  }

  void _handleSendInvites() {
    // In a real app, you would send invitation emails here.
    context.go('/setup-success');
  }

  void _handleSkip() {
    context.go('/setup-success');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    
                    // Family Invite Illustration
                    Center(
                      child: Container(
                        height: 140,
                        width: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryBlue.withOpacity(0.2),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(70),
                          child: Image.asset(
                            'assets/images/family_invite.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    const Text(
                      'Invite Your Family',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add at least 2 members to unlock all features for free',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  spreadRadius: -5,
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  // Dynamic List of Members
                                  ...List.generate(_members.length, (index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 24.0),
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.6),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(color: Colors.white, width: 1.5),
                                            ),
                                            child: Column(
                                              children: [
                                                _buildTextField(
                                                  controller: _members[index]['name']!, 
                                                  hintText: 'Member Name',
                                                  icon: Icons.person_outline,
                                                ),
                                                const SizedBox(height: 12),
                                                _buildTextField(
                                                  controller: _members[index]['email']!, 
                                                  hintText: 'Email Address',
                                                  icon: Icons.email_outlined,
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (_members.length > 1)
                                            Positioned(
                                              right: -10,
                                              top: -10,
                                              child: GestureDetector(
                                                onTap: () => _removeMember(index),
                                                child: Container(
                                                  padding: const EdgeInsets.all(4),
                                                  decoration: const BoxDecoration(
                                                    color: AppColors.errorRed,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  }),
                                  
                                  OutlinedButton.icon(
                                    onPressed: _addMember,
                                    icon: const Icon(Icons.add_circle_outline, size: 20),
                                    label: const Text('Add Another Member'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF2E7D7B),
                                      side: const BorderSide(color: Color(0xFF2E7D7B), width: 1.5),
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primaryBlue,
                            AppColors.accentPurple,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: _handleSendInvites,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Send Invites & Finish',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _handleSkip,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.white.withOpacity(0.8), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Skip for now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 20, color: AppColors.textPrimary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hintText, required IconData icon}) {
     return TextField(
      controller: controller,
      style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5), fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: AppColors.primaryBlue.withOpacity(0.7), size: 22),
        filled: true,
        fillColor: Colors.white.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 1),
        ),
      ),
    );
  }
}
