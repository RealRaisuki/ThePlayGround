import 'package:flutter/material.dart';

class TodoItem {
  final String id;
  String title;
  bool isCompleted;
  DateTime? dueDate;
  String categoryId;

  TodoItem({
    required this.id,
    required this.title,
    required this.isCompleted,
    this.dueDate,
    required this.categoryId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'dueDate': dueDate?.toIso8601String(),
      'categoryId': categoryId,
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

    return TodoItem(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? 'Untitled Task',
      isCompleted: json['isCompleted'] ?? false,
      dueDate: dueDate,
      categoryId: json['categoryId'] ?? 'personal',
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
    String? categoryId,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      categoryId: categoryId ?? this.categoryId,
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
    return 'TodoItem(id: $id, title: $title, isCompleted: $isCompleted, dueDate: $dueDate, categoryId: $categoryId)';
  }
}
