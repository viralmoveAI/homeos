import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/animated_gradient_background.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/maintenance_providers.dart';
import '../widgets/summary_card.dart';
import '../widgets/task_card.dart';
import '../widgets/add_task_bottom_sheet.dart';
import '../../domain/models/maintenance_task.dart';

class MaintenanceScreen extends ConsumerStatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  ConsumerState<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends ConsumerState<MaintenanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddTask() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTaskBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(maintenanceTasksProvider);

    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 100.0),
          child: FloatingActionButton.extended(
            onPressed: _showAddTask,
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            elevation: 8,
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Add Task',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: tasksAsync.when(
            data: (tasks) {
              final overdue = tasks
                  .where(
                    (t) => !t.isCompleted && t.dueDate.isBefore(DateTime.now()),
                  )
                  .length;
              final upcoming = tasks
                  .where(
                    (t) => !t.isCompleted && t.dueDate.isAfter(DateTime.now()),
                  )
                  .length;
              final completed = tasks.where((t) => t.isCompleted).length;

              final upcomingTasks = tasks.where((t) => !t.isCompleted).toList();
              final completedTasks = tasks.where((t) => t.isCompleted).toList();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Maintenance Calendar',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Keep your home in top shape',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: SummaryCard(
                            title: 'Overdue',
                            value: overdue.toString(),
                            color: AppColors.errorRed,
                            icon: Icons.warning_amber_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SummaryCard(
                            title: 'Upcoming',
                            value: upcoming.toString(),
                            color: AppColors.warningOrange,
                            icon: Icons.upcoming_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SummaryCard(
                            title: 'Completed',
                            value: completed.toString(),
                            color: AppColors.successGreen,
                            icon: Icons.check_circle_outline_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: Container(
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
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    24,
                                    20,
                                    16,
                                  ),
                                  child: Container(
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: TabBar(
                                      controller: _tabController,
                                      indicator: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.08,
                                            ),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      indicatorSize: TabBarIndicatorSize.tab,
                                      dividerColor: Colors.transparent,
                                      labelColor: AppColors.primaryBlue,
                                      unselectedLabelColor:
                                          AppColors.textSecondary,
                                      labelStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      tabs: [
                                        Tab(
                                          text:
                                              'Upcoming (${upcomingTasks.length})',
                                        ),
                                        Tab(
                                          text:
                                              'Completed (${completedTasks.length})',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: TabBarView(
                                    controller: _tabController,
                                    children: [
                                      _buildTaskList(
                                        upcomingTasks,
                                        'No pending tasks',
                                      ),
                                      _buildTaskList(
                                        completedTasks,
                                        'No completed tasks',
                                      ),
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
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(List<MaintenanceTask> tasks, String emptyMsg) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 64,
                color: AppColors.successGreen,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'All caught up!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              emptyMsg,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          task: task,
          onToggle: () => ref
              .read(maintenanceNotifierProvider.notifier)
              .toggleTaskCompletion(task.id, !task.isCompleted),
          onDelete: () => ref
              .read(maintenanceNotifierProvider.notifier)
              .deleteTask(task.id),
        );
      },
    );
  }
}
