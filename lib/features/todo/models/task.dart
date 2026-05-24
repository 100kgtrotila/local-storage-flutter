import 'package:flutter/material.dart';

enum TaskCategory { work, personal, shopping }

enum Priority { low, medium, high }

class Task {
  final int id;
  final String title;
  final bool isDone;
  final TaskCategory category;
  final Priority priority;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.title,
    required this.isDone,
    required this.category,
    required this.priority,
    required this.createdAt,
  });

  Color get priorityColor {
    switch (priority) {
      case Priority.high:
        return const Color(0xFFEF4444);
      case Priority.medium:
        return const Color(0xFFF59E0B);
      case Priority.low:
        return const Color(0xFF10B981);
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case TaskCategory.work:
        return Icons.work_outline_rounded;
      case TaskCategory.personal:
        return Icons.person_outline_rounded;
      case TaskCategory.shopping:
        return Icons.shopping_cart_outlined;
    }
  }

  Task copyWith({
    int? id,
    String? title,
    bool? isDone,
    TaskCategory? category,
    Priority? priority,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone,
      'category': category.index,
      'priority': priority.index,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      title: json['title'] as String,
      isDone: json['isDone'] as bool,
      category: TaskCategory.values[json['category'] as int],
      priority: Priority.values[json['priority'] as int],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
