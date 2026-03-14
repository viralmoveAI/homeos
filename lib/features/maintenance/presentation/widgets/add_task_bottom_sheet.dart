import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/maintenance_task.dart';
import '../providers/maintenance_providers.dart';

class AddTaskBottomSheet extends ConsumerStatefulWidget {
  final MaintenanceTask? task;

  const AddTaskBottomSheet({super.key, this.task});

  @override
  ConsumerState<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends ConsumerState<AddTaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late MaintenanceCategory _category;
  late MaintenancePriority _priority;
  late DateTime _dueDate;
  late bool _isRecurring;
  String? _season;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title);
    _descriptionController = TextEditingController(text: widget.task?.description);
    _category = widget.task?.category ?? MaintenanceCategory.general;
    _priority = widget.task?.priority ?? MaintenancePriority.medium;
    _dueDate = widget.task?.dueDate ?? DateTime.now().add(const Duration(days: 7));
    _isRecurring = widget.task?.isRecurring ?? false;
    _season = widget.task?.season;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final task = MaintenanceTask(
        id: widget.task?.id ?? '',
        title: _titleController.text,
        description: _descriptionController.text,
        category: _category,
        priority: _priority,
        dueDate: _dueDate,
        isRecurring: _isRecurring,
        season: _season,
        isCompleted: widget.task?.isCompleted ?? false,
      );

      if (widget.task == null) {
        ref.read(maintenanceNotifierProvider.notifier).addTask(task);
      } else {
        ref.read(maintenanceNotifierProvider.notifier).updateTask(task);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 32,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                    widget.task == null ? 'New Maintenance Task' : 'Edit Maintenance Task',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Title *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: 'e.g. Change HVAC Filters'),
                validator: (v) => v == null || v.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<MaintenanceCategory>(
                          value: _category,
                          items: MaintenanceCategory.values.map((c) {
                            return DropdownMenuItem(value: c, child: Text(c.displayName));
                          }).toList(),
                          onChanged: (v) => setState(() => _category = v!),
                          decoration: const InputDecoration(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Priority', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<MaintenancePriority>(
                          value: _priority,
                          items: MaintenancePriority.values.map((p) {
                            return DropdownMenuItem(value: p, child: Text(p.displayName));
                          }).toList(),
                          onChanged: (v) => setState(() => _priority = v!),
                          decoration: const InputDecoration(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Due Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _selectDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.textHint.withOpacity(0.2)),
                              borderRadius: BorderRadius.circular(16),
                              color: AppColors.surfaceWhite,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 20, color: AppColors.primaryBlue),
                                const SizedBox(width: 12),
                                Text(DateFormat('MM/dd/yyyy').format(_dueDate)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Season', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String?>(
                          value: _season,
                          items: [null, 'Spring', 'Summer', 'Autumn', 'Winter'].map((s) {
                            return DropdownMenuItem(value: s, child: Text(s ?? 'No season'));
                          }).toList(),
                          onChanged: (v) => setState(() => _season = v),
                          decoration: const InputDecoration(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Add some details...'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: _isRecurring,
                    onChanged: (v) => setState(() => _isRecurring = v!),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    activeColor: AppColors.primaryBlue,
                  ),
                  const Text('Recurring task', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(widget.task == null ? 'Create Task' : 'Update Task'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
