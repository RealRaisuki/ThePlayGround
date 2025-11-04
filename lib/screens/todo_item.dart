import 'package:flutter/material.dart';

enum TaskCategory {
  personal('Personal', Colors.green, Icons.person),
  work('Work', Colors.blue, Icons.work),
  shopping('Shopping', Colors.orange, Icons.shopping_cart),
  health('Health', Colors.red, Icons.favorite),
  urgent('Urgent', Colors.purple, Icons.warning);

  final String displayName;
  final Color color;
  final IconData icon;

  const TaskCategory(this.displayName, this.color, this.icon);
}

class TodoItem {
  final String id;
  String title;
  bool isCompleted;
  DateTime? dueDate;
  TaskCategory category;

  TodoItem({
    required this.id,
    required this.title,
    required this.isCompleted,
    this.dueDate,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'dueDate': dueDate?.toIso8601String(),
      'category': category.index,
    };
  }

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    DateTime? dueDate;
    try {
      if (json['dueDate'] != null && (json['dueDate'] as String).isNotEmpty) {
        dueDate = DateTime.tryParse(json['dueDate']);
        if (dueDate == null) {
          debugPrint('Warning: Failed to parse date: ${json['dueDate']}');
        }
      }
    } catch (e) {
      debugPrint('Error parsing date: $e');
    }

    //Safe category indexing with bounds checking
    final categoryIndex = json['category'] ?? 0;
    TaskCategory category;
    if (categoryIndex >= 0 && categoryIndex < TaskCategory.values.length) {
      category = TaskCategory.values[categoryIndex];
    } else {
      debugPrint(
        'Warning: Invalid category index: $categoryIndex, defaulting to personal',
      );
      category = TaskCategory.personal;
    }

    return TodoItem(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? 'Untitled Task',
      isCompleted: json['isCompleted'] ?? false,
      dueDate: dueDate,
      category: category,
    );
  }

  String get formattedDueDate {
    if (dueDate == null) return 'No due date';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);

    final difference = taskDate.difference(today).inDays;

    if (difference == 0) {
      return 'Today at ${_formatTime(dueDate!)}';
    } else if (difference == 1) {
      return 'Tomorrow at ${_formatTime(dueDate!)}';
    } else if (difference == -1) {
      return 'Yesterday at ${_formatTime(dueDate!)}';
    } else if (difference < 0) {
      return '${difference.abs()} days ago at ${_formatTime(dueDate!)}';
    } else if (difference < 7) {
      return 'In $difference days at ${_formatTime(dueDate!)}';
    } else {
      return '${_formatDate(dueDate!)} at ${_formatTime(dueDate!)}';
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final monthName = months[date.month - 1];
    final day = date.day;
    final year = date.year;

    return '$monthName $day, $year';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute;
    final period = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    return dueDate!.isBefore(now);
  }

  TodoItem copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? dueDate,
    TaskCategory? category,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TodoItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TodoItem(id: $id, title: $title, isCompleted: $isCompleted, dueDate: $dueDate, category: $category)';
  }
}

extension TaskCategoryExtension on TaskCategory {
  String get name => toString().split('.').last;

  static TaskCategory? fromString(String name) {
    try {
      return TaskCategory.values.firstWhere(
        (category) => category.name == name,
      );
    } catch (e) {
      debugPrint('Error converting string to TaskCategory: $e');
      return null;
    }
  }
}

class TodoItemUtils {
  static bool isDueToday(DateTime? dueDate) {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return taskDate == today;
  }

  static bool isDueTomorrow(DateTime? dueDate) {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return taskDate == tomorrow;
  }

  static int daysUntilDue(DateTime? dueDate) {
    if (dueDate == null) return -1;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return taskDate.difference(today).inDays;
  }
}
