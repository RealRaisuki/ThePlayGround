import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';

class CategoryService {
  static const String _categoriesKey = 'categories';

  Future<List<Category>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = prefs.getString(_categoriesKey);
    if (categoriesJson != null) {
      final List<dynamic> decoded = jsonDecode(categoriesJson);
      return decoded.map((json) => Category.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  Future<void> saveCategories(List<Category> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> encoded = categories
        .map((c) => c.toJson())
        .toList();
    await prefs.setString(_categoriesKey, jsonEncode(encoded));
  }

  Future<void> addCategory(Category category) async {
    final categories = await loadCategories();
    categories.add(category);
    await saveCategories(categories);
  }

  Future<void> updateCategory(Category category) async {
    final categories = await loadCategories();
    final index = categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      categories[index] = category;
      await saveCategories(categories);
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    final categories = await loadCategories();
    categories.removeWhere((c) => c.id == categoryId);
    await saveCategories(categories);
  }
}
