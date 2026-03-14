import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/maintenance_task.dart';

class TaskCard extends StatelessWidget {
  final MaintenanceTask task;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;

  const TaskCard({super.key, required this.task, this.onToggle, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isOverdue =
        !task.isCompleted && task.dueDate.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: _getCategoryColor(task.category),
                width: 4,
              ),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: task.isCompleted
                          ? AppColors.successGreen
                          : AppColors.textHint.withOpacity(0.3),
                      width: 2,
                    ),
                    color: task.isCompleted
                        ? AppColors.successGreen
                        : Colors.transparent,
                  ),
                  child: task.isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: task.isCompleted
                            ? AppColors.textHint
                            : AppColors.textPrimary,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: Colors.blue.shade100),
                          ),
                          child: Text(
                            task.category.displayName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: isOverdue
                              ? AppColors.errorRed
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM d, y').format(task.dueDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: isOverdue
                                ? AppColors.errorRed
                                : AppColors.textSecondary,
                            fontWeight: isOverdue
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.errorRed,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(MaintenanceCategory category) {
    switch (category) {
      case MaintenanceCategory.plumbing:
        return Colors.blue;
      case MaintenanceCategory.electrical:
        return Colors.orange;
      case MaintenanceCategory.cleaning:
        return Colors.green;
      case MaintenanceCategory.hvac:
        return Colors.teal;
      case MaintenanceCategory.garden:
        return Colors.lightGreen;
      case MaintenanceCategory.appliance:
        return Colors.redAccent;
      case MaintenanceCategory.general:
        return Colors.indigo;
      case MaintenanceCategory.other:
        return Colors.grey;
    }
  }
}
