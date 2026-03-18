import 'package:flutter/material.dart';

enum MealType {
  breakfast('Breakfast', Icons.wb_sunny_rounded, Color(0xFFFF9F43)),
  lunch('Lunch', Icons.light_mode_rounded, Color(0xFF28C76F)),
  teaTime('Tea Time', Icons.emoji_food_beverage_rounded, Color(0xFFFF9F43)),
  dinner('Dinner', Icons.nightlight_round, Color(0xFF9E7CFF));

  final String displayName;
  final IconData icon;
  final Color color;
  const MealType(this.displayName, this.icon, this.color);
}

class MealOption {
  final String id;
  final String name;
  final String emoji;
  final List<String> votes; // List of user IDs

  MealOption({
    required this.id,
    required this.name,
    required this.emoji,
    this.votes = const [],
  });

  MealOption copyWith({
    String? id,
    String? name,
    String? emoji,
    List<String>? votes,
  }) {
    return MealOption(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      votes: votes ?? this.votes,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'emoji': emoji, 'votes': votes};
  }

  factory MealOption.fromMap(Map<String, dynamic> map) {
    return MealOption(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      emoji: map['emoji'] ?? '',
      votes: List<String>.from(map['votes'] ?? []),
    );
  }
}

class MealPoll {
  final String id;
  final String creatorId; // Added for management
  final String creatorName;
  final DateTime date;
  final MealType type;
  final List<MealOption> options;
  final bool isActive;

  MealPoll({
    required this.id,
    required this.creatorId,
    required this.creatorName,
    required this.date,
    required this.type,
    required this.options,
    this.isActive = true,
  });

  MealPoll copyWith({
    String? id,
    String? creatorId,
    String? creatorName,
    DateTime? date,
    MealType? type,
    List<MealOption>? options,
    bool? isActive,
  }) {
    return MealPoll(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      date: date ?? this.date,
      type: type ?? this.type,
      options: options ?? this.options,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'creatorId': creatorId,
      'creatorName': creatorName,
      'date': date.toIso8601String(),
      'type': type.name,
      'options': options.map((e) => e.toMap()).toList(),
      'isActive': isActive,
    };
  }

  factory MealPoll.fromMap(Map<String, dynamic> map) {
    return MealPoll(
      id: map['id'] ?? '',
      creatorId: map['creatorId'] ?? '',
      creatorName: map['creatorName'] ?? '',
      date: DateTime.parse(map['date']),
      type: MealType.values.firstWhere((e) => e.name == map['type']),
      options: List<MealOption>.from(
        (map['options'] ?? []).map((e) => MealOption.fromMap(e)),
      ),
      isActive: map['isActive'] ?? true,
    );
  }
}
