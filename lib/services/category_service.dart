import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';

class CategoryService {
  static const String _baseCategoriesKey = 'categories';

  String _getCategoriesKey(String userId) => '${_baseCategoriesKey}_user_$userId';

  Future<List<Category>> loadCategories(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesKey = _getCategoriesKey(userId);
    final categoriesJson = prefs.getString(categoriesKey);
    if (categoriesJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(categoriesJson);
        return decoded.map((json) => Category.fromJson(json)).toList();
      } catch (e) {
        return [];
      }
    } else {
      return [];
    }
  }

  Future<void> saveCategories(List<Category> categories, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesKey = _getCategoriesKey(userId);
    final List<Map<String, dynamic>> encoded = categories
        .map((c) => c.toJson())
        .toList();
    await prefs.setString(categoriesKey, jsonEncode(encoded));
  }

  Future<void> addCategory(Category category, String userId) async {
    final categories = await loadCategories(userId);
    categories.add(category);
    await saveCategories(categories, userId);
  }

  Future<void> updateCategory(Category category, String userId) async {
    final categories = await loadCategories(userId);
    final index = categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      categories[index] = category;
      await saveCategories(categories, userId);
    }
  }

  Future<void> deleteCategory(String categoryId, String userId) async {
    final categories = await loadCategories(userId);
    categories.removeWhere((c) => c.id == categoryId);
    await saveCategories(categories, userId);
  }
}
