import 'package:flutter/material.dart';
import 'models/category.dart';
import 'services/category_service.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  List<Category> _categories = [];

  List<Category> get categories => _categories;

  Future<void> loadCategories() async {
    _categories = await _categoryService.loadCategories();
    notifyListeners();
  }

  Future<void> addCategory(Category category) async {
    await _categoryService.addCategory(category);
    await loadCategories();
  }

  Future<void> updateCategory(Category category) async {
    await _categoryService.updateCategory(category);
    await loadCategories();
  }

  Future<void> deleteCategory(String categoryId) async {
    await _categoryService.deleteCategory(categoryId);
    await loadCategories();
  }
}
