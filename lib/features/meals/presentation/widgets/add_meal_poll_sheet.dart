import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/meals_providers.dart';
import '../../domain/models/meal_poll.dart';
import '../../../../core/providers/auth_providers.dart';

class AddMealPollSheet extends ConsumerStatefulWidget {
  const AddMealPollSheet({super.key});

  @override
  ConsumerState<AddMealPollSheet> createState() => _AddMealPollSheetState();
}

class _AddMealPollSheetState extends ConsumerState<AddMealPollSheet> {
  MealType _selectedType = MealType.dinner;
  final TextEditingController _optionController = TextEditingController();
  final List<MealOption> _options = [];
  final _uuid = const Uuid();

  void _addOption() {
    if (_optionController.text.trim().isEmpty) return;

    // Simple emoji logic
    String emoji = '🍽️';
    final text = _optionController.text.toLowerCase();
    if (text.contains('pizza'))
      emoji = '🍕';
    else if (text.contains('burger'))
      emoji = '🍔';
    else if (text.contains('pasta') || text.contains('spaghetti'))
      emoji = '🍝';
    else if (text.contains('chicken'))
      emoji = '🍗';
    else if (text.contains('rice'))
      emoji = '🍚';
    else if (text.contains('salad'))
      emoji = '🥗';
    else if (text.contains('sandwich'))
      emoji = '🥪';
    else if (text.contains('tea'))
      emoji = '☕';
    else if (text.contains('palan'))
      emoji = '🥣';

    setState(() {
      _options.add(
        MealOption(
          id: _uuid.v4(),
          name: _optionController.text.trim(),
          emoji: emoji,
        ),
      );
      _optionController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Create Meal Poll',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),

            // Meal Type Selection
            const Text(
              'Select Meal Time',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: MealType.values.map((type) {
                final isSelected = _selectedType == type;
                return GestureDetector(
                  onTap: () => setState(() => _selectedType = type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? type.color
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? type.color : Colors.white,
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: type.color.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          type.icon,
                          color: isSelected ? Colors.white : type.color,
                          size: 20,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          type.displayName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),
            const Text(
              'Add Menu Options',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _optionController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Pasta Carbonara',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onSubmitted: (_) => _addOption(),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _addOption,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.add_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _options.length,
                itemBuilder: (context, index) {
                  final option = _options[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        Text(
                          option.emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            option.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline_rounded,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _options.removeAt(index)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _options.isEmpty
                    ? null
                    : () async {
                        final user = ref.read(userProfileProvider).value;
                        final creatorName = user?['firstName'] ?? 'User';
                        final creatorId = ref.read(effectiveUidProvider) ?? '';

                        final poll = MealPoll(
                          id: '', // Will be set by Firestore
                          creatorId: creatorId,
                          creatorName: creatorName,
                          date: DateTime.now(),
                          type: _selectedType,
                          options: _options,
                        );

                        await ref
                            .read(mealNotifierProvider.notifier)
                            .addPoll(poll);
                        Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Publish Poll',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
