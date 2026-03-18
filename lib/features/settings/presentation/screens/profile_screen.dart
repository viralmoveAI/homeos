import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/database_service.dart';
import '../../../../shared/widgets/animated_gradient_background.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../../core/providers/auth_providers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _role = 'Member';
  bool _isInitialized = false;

  bool _healthAlerts = true;
  bool _pollNotifications = false;
  bool _vaultExpiry = true;
  bool _tfaEnabled = false;

  final _authService = AuthService();
  final _dbService = DatabaseService();
  bool _isInviting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text('Are you sure you want to log out?')],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Handle logout logic here
              Navigator.pop(context);
              context.go('/login');
            },
            child: const Text('LOGOUT', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.grey[50]?.withOpacity(0.4),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Profile & Settings',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: profileAsync.when(
          data: (profile) {
            // Update controllers ONLY on initial load
            if (profile != null && !_isInitialized) {
              final fullName =
                  '${profile['firstName'] ?? ''} ${profile['lastName'] ?? ''}'
                      .trim();
              _nameController.text = fullName;
              _emailController.text = profile['email'] ?? '';
              _role = profile['role'] ?? 'Member';
              _isInitialized = true;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
              child: Column(
                children: [
                  _buildProfileHeader(profile),
                  const SizedBox(height: 30),
                  _buildUserDetailsCard(profile),
                  const SizedBox(height: 20),
                  _buildAppPreferencesCard(),
                  const SizedBox(height: 20),
                  _buildAppCustomizationCard(),
                  const SizedBox(height: 20),
                  _buildFamilyMembersSection(),
                  const SizedBox(height: 20),
                  _buildAccountSecuritySection(),
                  const SizedBox(height: 30),
                  _buildAccountActions(),
                  const SizedBox(height: 40),
                  _buildLogoutSection(),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Error loading profile: $err'),
                TextButton(
                  onPressed: () => ref.invalidate(userProfileProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic>? profile) {
    final firstName = profile?['firstName'] ?? 'User';
    final role = profile?['role'] ?? 'Member';

    return Column(
      children: [
        UserAvatar(name: firstName, radius: 60),
        const SizedBox(height: 16),
        Text(
          profile != null
              ? '${profile['firstName'] ?? ''} ${profile['lastName'] ?? ''}'
              : 'Loading...',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          role,
          style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            'Change Photo',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserDetailsCard(Map<String, dynamic>? profile) {
    return _SettingsCard(
      title: 'User Profile Details',
      child: Column(
        children: [
          _buildEditableField('Full Name', _nameController),
          _buildInfoField('Email', _emailController.text),
          _buildRoleDropdown(),
          const SizedBox(height: 16),
          _buildSaveButton(profile),
        ],
      ),
    );
  }

  Widget _buildSaveButton(Map<String, dynamic>? profile) {
    return ElevatedButton(
      onPressed: () async {
        final names = _nameController.text.split(' ');
        final firstName = names.isNotEmpty ? names[0] : '';
        final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

        try {
          await _dbService.saveUserProfile({
            'firstName': firstName,
            'lastName': lastName,
            'role': _role,
          });
          Fluttertoast.showToast(msg: "Profile updated!");
        } catch (e) {
          Fluttertoast.showToast(msg: "Error: $e");
        }
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 45),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text('Update Profile'),
    );
  }

  Widget _buildAppPreferencesCard() {
    return _SettingsCard(
      title: 'App Preferences',
      child: Column(
        children: [
          _buildToggleTile(
            'Home Health Alerts',
            _healthAlerts,
            (v) => setState(() => _healthAlerts = v),
          ),
          _buildToggleTile(
            'Poll Notifications',
            _pollNotifications,
            (v) => setState(() => _pollNotifications = v),
          ),
          _buildToggleTile(
            'Vault Document Expiry',
            _vaultExpiry,
            (v) => setState(() => _vaultExpiry = v),
          ),
          _buildActionTile(
            'Change Password',
            Icons.lock_outline_rounded,
            _showChangePasswordDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildAppCustomizationCard() {
    return _SettingsCard(
      title: 'App Customization - Color Change Option',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gradient Color Change Option',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: AppThemeMode.values.map((mode) {
              final themeState = ref.watch(appThemeNavigatorProvider);
              final isSelected = themeState.mode == mode;

              // Use the actual current custom colors if it's the custom mode
              final previewState = mode == AppThemeMode.custom
                  ? themeState
                  : ThemeState(mode: mode);

              return GestureDetector(
                onTap: () {
                  if (mode == AppThemeMode.custom) {
                    _showCustomColorPicker();
                  } else {
                    ref.read(appThemeNavigatorProvider.notifier).setTheme(mode);
                  }
                },
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: previewState.gradient,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(
                                  color: AppColors.textPrimary,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white)
                            : (mode == AppThemeMode.custom
                                  ? const Icon(
                                      Icons.colorize,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : null),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mode.displayName,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSecuritySection() {
    return _SettingsCard(
      title: 'Account & Security',
      child: Column(
        children: [
          _buildActionTile('Family Members', Icons.group_outlined, () {}),
          _buildToggleTile(
            'TFA (Two-Factor Authentication)',
            _tfaEnabled,
            (v) => setState(() => _tfaEnabled = v),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActions() {
    return Column(
      children: [
        _buildSettingsTile(Icons.help_center_outlined, 'Help Center', () {}),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'App version: 1.4.2',
            style: TextStyle(color: AppColors.textHint, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutSection() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _showLogoutConfirmation,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'LOGOUT',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
        ),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: _role,
        decoration: InputDecoration(
          labelText: 'Household Role',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: ['Manager', 'Admin', 'Member'].map((role) {
          return DropdownMenuItem(value: role, child: Text(role));
        }).toList(),
        onChanged: (v) => setState(() => _role = v!),
      ),
    );
  }

  Widget _buildToggleTile(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      activeColor: AppColors.primaryBlue,
    );
  }

  Widget _buildActionTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      trailing: Icon(icon, size: 20),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showCustomColorPicker() {
    final themeState = ref.read(appThemeNavigatorProvider);
    Color color1 = themeState.customColors[0];
    Color color2 = themeState.customColors[1];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Gradient'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Pick First Color'),
              const SizedBox(height: 10),
              ColorPicker(
                pickerColor: color1,
                onColorChanged: (c) => color1 = c,
                pickerAreaHeightPercent: 0.5,
                enableAlpha: false,
                displayThumbColor: true,
              ),
              const Divider(),
              const Text('Pick Second Color'),
              const SizedBox(height: 10),
              ColorPicker(
                pickerColor: color2,
                onColorChanged: (c) => color2 = c,
                pickerAreaHeightPercent: 0.5,
                enableAlpha: false,
                displayThumbColor: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(appThemeNavigatorProvider.notifier).setCustomColors([
                color1,
                color2,
              ]);
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      onTap: onTap,
    );
  }

  void _showChangePasswordDialog() {
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Change Password'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter your new password below.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  obscureText: true,
                  validator: (v) => v == null || v.length < 6
                      ? 'Minimum 6 characters required'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  obscureText: true,
                  validator: (v) => v != passwordController.text
                      ? 'Passwords do not match'
                      : null,
                ),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        setDialogState(() => isLoading = true);
                        try {
                          await _authService.updatePassword(
                            passwordController.text.trim(),
                          );
                          if (mounted) {
                            Navigator.pop(context);
                            Fluttertoast.showToast(
                              msg: "Password updated successfully!",
                              backgroundColor: Colors.green,
                            );
                          }
                        } catch (e) {
                          Fluttertoast.showToast(
                            msg: "Error: ${e.toString()}",
                            backgroundColor: Colors.red,
                          );
                        } finally {
                          setDialogState(() => isLoading = false);
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('UPDATE'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Family Management UI ────────────────────────────────────────────────

  Widget _buildFamilyMembersSection() {
    return _SettingsCard(
      title: 'Family Members',
      child: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _dbService.getFamilyMembers(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final members = snapshot.data?.docs ?? [];
              if (members.isEmpty) {
                return const Text(
                  'No family members added yet.',
                  style: TextStyle(color: AppColors.textSecondary),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: members.length,
                separatorBuilder: (context, index) =>
                    Divider(color: Colors.grey.shade100),
                itemBuilder: (context, index) {
                  final member = members[index].data() as Map<String, dynamic>;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                      child: Text(
                        (member['name'] ?? 'M')[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      member['name'] ?? 'Member',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(member['email'] ?? ''),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.person_remove_outlined,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () => _confirmRemoveMember(
                        member['uid'],
                        member['name'] ?? 'Member',
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showInviteDialog,
            icon: const Icon(Icons.person_add_outlined, size: 20),
            label: const Text('Invite Family Member'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: AppColors.primaryBlue.withOpacity(0.05),
              foregroundColor: AppColors.primaryBlue,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.primaryBlue),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInviteDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Invite Family Member'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter details to create an account for your family member.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Preferred name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || !v.contains('@')
                      ? 'Valid email required'
                      : null,
                ),
                if (_isInviting)
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isInviting ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isInviting
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        setDialogState(() => _isInviting = true);
                        try {
                          await _authService.inviteFamilyMember(
                            name: nameController.text.trim(),
                            email: emailController.text.trim(),
                          );

                          if (mounted) {
                            Navigator.pop(context);
                            Fluttertoast.showToast(
                              msg: "Invitation sent successfully!",
                              backgroundColor: Colors.green,
                            );
                          }
                        } catch (e) {
                          Fluttertoast.showToast(
                            msg: "Error: $e",
                            backgroundColor: Colors.red,
                          );
                        } finally {
                          setDialogState(() => _isInviting = false);
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('INVITE'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemoveMember(String uid, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text(
          'Are you sure you want to remove $name from your family?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _dbService.removeFamilyMember(uid);
                Fluttertoast.showToast(msg: "Member removed");
              } catch (e) {
                Fluttertoast.showToast(msg: "Error: $e");
              }
            },
            child: const Text('REMOVE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SettingsCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
