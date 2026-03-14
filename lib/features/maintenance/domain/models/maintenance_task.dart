import 'package:cloud_firestore/cloud_firestore.dart';

enum MaintenanceCategory {
  general,
  plumbing,
  electrical,
  hvac,
  cleaning,
  garden,
  appliance,
  other;

  String get displayName {
    switch (this) {
      case MaintenanceCategory.general:
        return 'General';
      case MaintenanceCategory.plumbing:
        return 'Plumbing';
      case MaintenanceCategory.electrical:
        return 'Electrical';
      case MaintenanceCategory.hvac:
        return 'HVAC';
      case MaintenanceCategory.cleaning:
        return 'Cleaning';
      case MaintenanceCategory.garden:
        return 'Garden';
      case MaintenanceCategory.appliance:
        return 'Appliance';
      case MaintenanceCategory.other:
        return 'Other';
    }
  }
}

enum MaintenancePriority {
  low,
  medium,
  high,
  urgent;

  String get displayName {
    switch (this) {
      case MaintenancePriority.low:
        return 'Low';
      case MaintenancePriority.medium:
        return 'Medium';
      case MaintenancePriority.high:
        return 'High';
      case MaintenancePriority.urgent:
        return 'Urgent';
    }
  }
}

class MaintenanceTask {
  final String id;
  final String title;
  final MaintenanceCategory category;
  final MaintenancePriority priority;
  final DateTime dueDate;
  final String? season;
  final String? description;
  final bool isRecurring;
  final bool isCompleted;
  final DateTime? createdAt;

  MaintenanceTask({
    required this.id,
    required this.title,
    required this.category,
    required this.priority,
    required this.dueDate,
    this.season,
    this.description,
    this.isRecurring = false,
    this.isCompleted = false,
    this.createdAt,
  });

  MaintenanceTask copyWith({
    String? id,
    String? title,
    MaintenanceCategory? category,
    MaintenancePriority? priority,
    DateTime? dueDate,
    String? season,
    String? description,
    bool? isRecurring,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return MaintenanceTask(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      season: season ?? this.season,
      description: description ?? this.description,
      isRecurring: isRecurring ?? this.isRecurring,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category.name,
      'priority': priority.name,
      'dueDate': Timestamp.fromDate(dueDate),
      'season': season,
      'description': description,
      'isRecurring': isRecurring,
      'isCompleted': isCompleted,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory MaintenanceTask.fromJson(Map<String, dynamic> json, String id) {
    return MaintenanceTask(
      id: id,
      title: json['title'] ?? '',
      category: MaintenanceCategory.values.firstWhere(
        (e) => e.name == (json['category'] ?? 'general'),
        orElse: () => MaintenanceCategory.general,
      ),
      priority: MaintenancePriority.values.firstWhere(
        (e) => e.name == (json['priority'] ?? 'medium'),
        orElse: () => MaintenancePriority.medium,
      ),
      dueDate: (json['dueDate'] as Timestamp).toDate(),
      season: json['season'],
      description: json['description'],
      isRecurring: json['isRecurring'] ?? false,
      isCompleted: json['isCompleted'] ?? false,
      createdAt: json['createdAt'] != null ? (json['createdAt'] as Timestamp).toDate() : null,
    );
  }
}
