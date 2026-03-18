import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/family_hub_providers.dart';
import '../../../../shared/widgets/user_avatar.dart';

class CreateGroupSheet extends ConsumerStatefulWidget {
  const CreateGroupSheet({super.key});

  @override
  ConsumerState<CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends ConsumerState<CreateGroupSheet> {
  final _nameController = TextEditingController();
  String _selectedEmoji = '👨‍👩‍👧';
  bool _loading = false;
  final Set<String> _selectedMembers = {};

  static const _emojis = [
    // Family & People
    '👨‍👩‍👧', '👨‍👩‍👦‍👦', '👵', '👴', '👶', '❤️', '🫂',
    // Home & Life
    '🏠', '🏡', '🏢', '🍳', '☕', '🍷', '🛋️',
    // Nature & Travel
    '🌴', '🏖️', '⛰️', '✈️', '🚗', '🚲', '🌎',
    // Activities & Hobbies
    '🎉', '🎈', '📸', '🎨', '🎵', '🎸', '🎮',
    // Food & Drink
    '🍕', '🍔', '🍰', '🍦', '🍎', '🍓', '🍣',
    // Animals & Fun
    '🐾', '🐶', '🐱', '🐼', '🦄', '🌟', '🚀',
    // Work & School
    '💼', '📚', '✏️', '💻', '💡', '📅', '🏆',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _loading = true);
    await ref
        .read(familyHubServiceProvider)
        .createChatGroup(
          name: name,
          emoji: _selectedEmoji,
          members: _selectedMembers.toList(),
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF0F4FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Create Chat Group',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose an emoji',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _emojis.map((e) {
                      final isSelected = e == _selectedEmoji;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedEmoji = e),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryBlue.withOpacity(0.2)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryBlue
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              e,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Group name',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g. Family Funs! 🎉',
                      hintStyle: const TextStyle(color: AppColors.textHint),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Select Members',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ref
                      .watch(familyMembersProvider)
                      .when(
                        data: (members) {
                          final otherMembers = members
                              .where(
                                (m) =>
                                    m['uid'] !=
                                    ref
                                        .read(familyHubServiceProvider)
                                        .currentUid,
                              )
                              .toList();

                          if (otherMembers.isEmpty) {
                            return const Text(
                              'No family members to add.',
                              style: TextStyle(color: AppColors.textHint),
                            );
                          }

                          return SizedBox(
                            height: 90,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: otherMembers.length,
                              itemBuilder: (context, index) {
                                final memberData = otherMembers[index];
                                final memberId = memberData['uid'] as String;
                                final memberName =
                                    memberData['name'] ??
                                    memberData['firstName'] ??
                                    'User';
                                final imageUrl =
                                    memberData['photoUrl'] as String?;
                                final isSelected = _selectedMembers.contains(
                                  memberId,
                                );

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedMembers.remove(memberId);
                                      } else {
                                        _selectedMembers.add(memberId);
                                      }
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: Column(
                                      children: [
                                        Stack(
                                          children: [
                                            AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              padding: const EdgeInsets.all(3),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: isSelected
                                                      ? AppColors.primaryBlue
                                                      : Colors.transparent,
                                                  width: 2,
                                                ),
                                              ),
                                              child: UserAvatar(
                                                name: memberName,
                                                imageUrl: imageUrl,
                                                radius: 26,
                                              ),
                                            ),
                                            if (isSelected)
                                              Positioned(
                                                right: 0,
                                                bottom: 0,
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    2,
                                                  ),
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: AppColors
                                                            .primaryBlue,
                                                        shape: BoxShape.circle,
                                                      ),
                                                  child: const Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          memberName.split(' ').first,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? AppColors.primaryBlue
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, st) => Text(
                          'Error: $e',
                          style: const TextStyle(color: AppColors.errorRed),
                        ),
                      ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primaryBlue,
                            AppColors.accentPurple,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _loading ? null : _create,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Create Group',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
