import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../screens/todo_item.dart';

class StorageService {
  final String userId;

  StorageService({required this.userId});

  String get _storageKey => 'tasks_$userId';

  Future<List<TodoItem>> loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getStringList(_storageKey) ?? [];
      final List<TodoItem> tasks = [];

      int successfulLoads = 0;
      int failedLoads = 0;

      for (final jsonString in tasksJson) {
        try {
          final Map<String, dynamic> taskMap = jsonDecode(jsonString);
          if (taskMap.containsKey('category') && taskMap['category'] is int) {
            taskMap['categoryId'] = 'personal'; // Default category
          } else if (taskMap.containsKey('category') && taskMap['category'] is String) {
            taskMap['categoryId'] = taskMap['category'];
          }
          final task = TodoItem.fromJson(taskMap);

          // Validate the loaded task
          if (task.title.isNotEmpty) {
            tasks.add(task);
            successfulLoads++;
          } else {
            failedLoads++;
            debugPrint('Warning: Loaded task with empty title, skipping');
          }
        } catch (e) {
          failedLoads++;
          debugPrint('Error parsing task: $e');
          debugPrint('Problematic JSON: $jsonString');
        }
      }

      if (failedLoads > 0) {
        debugPrint(
          'StorageService: Successfully loaded $successfulLoads tasks, $failedLoads failed',
        );
      }

      return tasks;
    } catch (e) {
      debugPrint('Error loading tasks from SharedPreferences: $e');
      return [];
    }
  }

  Future<bool> saveTasks(List<TodoItem> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Validate tasks before saving
      if (tasks.any((task) => task.title.isEmpty)) {
        debugPrint('Warning: Attempting to save tasks with empty titles');
      }

      final tasksJson = tasks.map((task) => jsonEncode(task.toJson())).toList();
      final success = await prefs.setStringList(_storageKey, tasksJson);

      if (success) {
        debugPrint(
          'StorageService: Successfully saved ${tasks.length} tasks for user $userId',
        );
      } else {
        debugPrint('Error: Failed to save tasks to SharedPreferences');
      }

      return success;
    } catch (e) {
      debugPrint('Error saving tasks to SharedPreferences: $e');
      return false;
    }
  }

  // Utility methods for better data management
  Future<bool> clearAllTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.remove(_storageKey);
      if (success) {
        debugPrint('StorageService: Cleared all tasks for user $userId');
      }
      return success;
    } catch (e) {
      debugPrint('Error clearing tasks: $e');
      return false;
    }
  }

  Future<int> getTaskCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getStringList(_storageKey) ?? [];
      return tasksJson.length;
    } catch (e) {
      debugPrint('Error getting task count: $e');
      return 0;
    }
  }

  // Backup/restore functions
  Future<String?> exportTasks() async {
    try {
      final tasks = await loadTasks();
      final exportData = {
        'exportedAt': DateTime.now().toIso8601String(),
        'taskCount': tasks.length,
        'userId': userId,
        'tasks': tasks.map((task) => task.toJson()).toList(),
      };
      return jsonEncode(exportData);
    } catch (e) {
      debugPrint('Error exporting tasks: $e');
      return null;
    }
  }

  Future<bool> importTasks(String jsonData) async {
    try {
      final Map<String, dynamic> importData = jsonDecode(jsonData);
      final List<dynamic> tasksJson = importData['tasks'] ?? [];

      final List<TodoItem> tasks = [];
      for (final taskJson in tasksJson) {
        try {
          final task = TodoItem.fromJson(taskJson);
          tasks.add(task);
        } catch (e) {
          debugPrint('Error importing task: $e');
        }
      }

      return await saveTasks(tasks);
    } catch (e) {
      debugPrint('Error importing tasks: $e');
      return false;
    }
  }
}
