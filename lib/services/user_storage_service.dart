import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../user/users.dart';

class UserStorageService {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'currentUser';

  Future<void> _saveUsers(List<User> users) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = users.map((user) => user.toJson()).toList();
      await prefs.setString(_usersKey, json.encode(usersJson));
      debugPrint('UserStorageService: Saved ${users.length} users');
    } catch (e) {
      debugPrint('Error saving users: $e');
      throw Exception('Failed to save user data');
    }
  }

  Future<List<User>> _getUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);
      if (usersJson != null) {
        final List<dynamic> usersList = json.decode(usersJson);
        final users = usersList.map((json) => User.fromJson(json)).toList();
        debugPrint('UserStorageService: Loaded ${users.length} users');
        return users;
      }
      return [];
    } catch (e) {
      debugPrint('Error loading users: $e');
      return [];
    }
  }

  Future<User?> findUserByUsername(String username) async {
    final users = await _getUsers();
    try {
      return users.firstWhere((user) => user.username == username);
    } catch (e) {
      return null;
    }
  }

  Future<User> createUser(
    String username,
    String password,
    String personalCode,
  ) async {
    final users = await _getUsers();
    final existingUser = await findUserByUsername(username);

    if (existingUser != null) {
      throw Exception('Username already exists');
    }

    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: username,
      password: password, // In a real app, hash this password
      personalCode: personalCode,
      createdAt: DateTime.now(),
    );

    users.add(newUser);
    await _saveUsers(users);
    debugPrint('UserStorageService: Created new user: ${newUser.username}');
    return newUser;
  }

  Future<bool> updateUser(User updatedUser) async {
    try {
      final users = await _getUsers();
      final index = users.indexWhere((user) => user.id == updatedUser.id);
      if (index != -1) {
        users[index] = updatedUser;
        await _saveUsers(users);
        debugPrint('UserStorageService: Updated user: ${updatedUser.username}');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating user: $e');
      return false;
    }
  }

  Future<bool> saveCurrentUser(UserSession session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, json.encode(session.toJson()));
      debugPrint(
        'UserStorageService: Saved current user session for ${session.user.username}',
      );
      return true;
    } catch (e) {
      debugPrint('Error saving current user: $e');
      return false;
    }
  }

  Future<UserSession?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString(_currentUserKey);
      if (sessionJson != null) {
        final session = UserSession.fromJson(json.decode(sessionJson));
        debugPrint(
          'UserStorageService: Loaded current user session for ${session.user.username}',
        );
        return session;
      }
      return null;
    } catch (e) {
      debugPrint('Error loading current user: $e');
      return null;
    }
  }

  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
      debugPrint('UserStorageService: Logged out');
      return true;
    } catch (e) {
      debugPrint('Error logging out: $e');
      return false;
    }
  }

  Future<bool> resetPassword(
    String username,
    String personalCode,
    String newPassword,
  ) async {
    try {
      final user = await findUserByUsername(username);

      if (user == null) {
        throw Exception('User not found');
      }

      if (user.personalCode != personalCode) {
        throw Exception('Invalid personal code');
      }

      final updatedUser = user.copyWith(password: newPassword);
      return await updateUser(updatedUser);
    } catch (e) {
      debugPrint('Error resetting password: $e');
      rethrow;
    }
  }

  Future<bool> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_usersKey);
      await prefs.remove(_currentUserKey);
      debugPrint('UserStorageService: Cleared all user data');
      return true;
    } catch (e) {
      debugPrint('Error clearing user data: $e');
      return false;
    }
  }
}
