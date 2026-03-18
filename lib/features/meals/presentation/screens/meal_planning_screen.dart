import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/animated_gradient_background.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/auth_providers.dart';
import '../providers/meals_providers.dart';
import '../widgets/add_meal_poll_sheet.dart';
import '../../domain/models/meal_poll.dart';
import 'package:intl/intl.dart';

class MealPlanningScreen extends ConsumerStatefulWidget {
  const MealPlanningScreen({super.key});

  @override
  ConsumerState<MealPlanningScreen> createState() => _MealPlanningScreenState();
}

class _MealPlanningScreenState extends ConsumerState<MealPlanningScreen> {
  @override
  Widget build(BuildContext context) {
    final pollsAsync = ref.watch(mealPollsProvider);

    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: pollsAsync.when(
                  data: (polls) {
                    if (polls.isEmpty) return _buildEmptyState();
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                      itemCount: polls.length,
                      itemBuilder: (context, index) {
                        return _buildPollCard(polls[index]);
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Error: $e')),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useRootNavigator: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddMealPollSheet(),
          ),
          backgroundColor: AppColors.primaryBlue,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text(
            'New Poll',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textPrimary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Meal Planner',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -1,
                        ),
                      ),
                      Text(
                        'What\'s cooking today?',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warningOrange.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.warningOrange.withOpacity(0.2),
                    ),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu_rounded,
                    color: AppColors.warningOrange,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPollCard(MealPoll poll) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: poll.type.color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            poll.type.icon,
                            color: poll.type.color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              poll.type.displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              DateFormat('EEEE, MMM d').format(poll.date),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        color: AppColors.textHint,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onSelected: (val) {
                        if (val == 'delete') {
                          ref
                              .read(mealNotifierProvider.notifier)
                              .deletePoll(poll.id);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...poll.options.map((option) => _buildOption(poll, option)),
                const SizedBox(height: 12),
                Text(
                  'Created by ${poll.creatorName}',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOption(MealPoll poll, MealOption option) {
    final totalVotes = poll.options.fold<int>(
      0,
      (sum, e) => sum + e.votes.length,
    );
    final percentage = totalVotes == 0 ? 0.0 : option.votes.length / totalVotes;
    final isVoted = option.votes.contains(ref.watch(effectiveUidProvider));

    return GestureDetector(
      onTap: () =>
          ref.read(mealNotifierProvider.notifier).vote(poll.id, option.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(isVoted ? 0.6 : 0.4),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isVoted
                ? poll.type.color.withOpacity(0.7)
                : Colors.white.withOpacity(0.5),
            width: isVoted ? 2 : 1.5,
          ),
          boxShadow: [
            if (isVoted)
              BoxShadow(
                color: poll.type.color.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Stack(
          children: [
            // Progress Bar
            FractionallySizedBox(
              widthFactor: percentage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: poll.type.color.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      option.emoji,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option.name,
                      style: TextStyle(
                        fontWeight: isVoted ? FontWeight.w900 : FontWeight.w700,
                        color: AppColors.textPrimary.withOpacity(0.9),
                        fontSize: 15,
                      ),
                    ),
                  ),
                  if (option.votes.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: poll.type.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${option.votes.length}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: poll.type.color.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  if (isVoted)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.successGreen,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fastfood_rounded,
              size: 64,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No meal polls yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create a poll and let everyone vote!',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
