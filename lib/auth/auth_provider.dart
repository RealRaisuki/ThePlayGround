import 'package:flutter/foundation.dart';
import '../user/users.dart';
import '../services/user_storage_service.dart';

class AuthProvider with ChangeNotifier {
  final UserStorageService _storageService = UserStorageService();
  UserSession? _currentUser;

  UserSession? get currentUser => _currentUser;

  Future<bool> login(String username, String password) async {
    final user = await _storageService.findUserByUsername(username);

    if (user != null && user.password == password) {
      _currentUser = UserSession(user: user, loginTime: DateTime.now());
      await _storageService.saveCurrentUser(_currentUser!);
      notifyListeners();
      return true;
    }

    return false;
  }

  Future<void> register(
    String username,
    String password,
    String personalCode,
  ) async {
    try {
      final newUser = await _storageService.createUser(
        username,
        password,
        personalCode,
      );
      _currentUser = UserSession(user: newUser, loginTime: DateTime.now());
      await _storageService.saveCurrentUser(_currentUser!);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await _storageService.logout();
    notifyListeners();
  }

  Future<void> checkCurrentUser() async {
    _currentUser = await _storageService.getCurrentUser();
    notifyListeners();
  }

  Future<void> resetPassword(
    String username,
    String personalCode,
    String newPassword,
  ) async {
    try {
      await _storageService.resetPassword(username, personalCode, newPassword);
    } catch (e) {
      rethrow;
    }
  }
}
