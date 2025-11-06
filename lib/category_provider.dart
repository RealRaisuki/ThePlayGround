import 'package:flutter/material.dart';
import 'models/category.dart';
import 'services/category_service.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  List<Category> _categories = [];

  List<Category> get categories => _categories;

  Future<void> loadCategories(String userId) async {
    _categories = await _categoryService.loadCategories(userId);
    notifyListeners();
  }

  Future<void> addCategory(Category category, String userId) async {
    await _categoryService.addCategory(category, userId);
    await loadCategories(userId);
  }

  Future<void> updateCategory(Category category, String userId) async {
    await _categoryService.updateCategory(category, userId);
    await loadCategories(userId);
  }

  Future<void> deleteCategory(String categoryId, String userId) async {
    await _categoryService.deleteCategory(categoryId, userId);
    await loadCategories(userId);
  }
}
