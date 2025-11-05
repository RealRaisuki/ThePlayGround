import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../category_provider.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, child) {
          if (provider.categories.isEmpty) {
            return const Center(child: Text('No categories yet.'));
          }
          return ListView.builder(
            itemCount: provider.categories.length,
            itemBuilder: (context, index) {
              final category = provider.categories[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: category.color,
                  radius: 15,
                ),
                title: Text(category.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showCategoryDialog(context, provider, category: category),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => provider.deleteCategory(category.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(context, Provider.of<CategoryProvider>(context, listen: false)),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, CategoryProvider provider, {Category? category}) {
    final isEditing = category != null;
    final nameController = TextEditingController(text: isEditing ? category.name : '');
    var selectedColor = isEditing ? category.color : Colors.blue;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Category' : 'Add Category'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Category Name'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text('Color:'),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () async {
                          final color = await _showColorPicker(context, selectedColor);
                          if (color != null) {
                            setState(() {
                              selectedColor = color;
                            });
                          }
                        },
                        child: CircleAvatar(
                          backgroundColor: selectedColor,
                          radius: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text;
                if (name.isNotEmpty) {
                  if (isEditing) {
                    provider.updateCategory(category.copyWith(name: name, color: selectedColor));
                  } else {
                    provider.addCategory(Category(id: DateTime.now().toString(), name: name, color: selectedColor));
                  }
                  Navigator.of(context).pop();
                }
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  Future<Color?> _showColorPicker(BuildContext context, Color initialColor) {
    return showDialog<Color>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: BlockPicker( // This is just an example, you might need to add a color picker dependency
              pickerColor: initialColor,
              onColorChanged: (color) {
                Navigator.of(context).pop(color);
              },
            ),
          ),
        );
      },
    );
  }
}

class BlockPicker extends StatelessWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;

  const BlockPicker({super.key, required this.pickerColor, required this.onColorChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
        Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
        Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
        Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
        Colors.brown, Colors.grey, Colors.blueGrey, Colors.black,
      ].map((color) => GestureDetector(
        onTap: () => onColorChanged(color),
        child: CircleAvatar(
          backgroundColor: color,
          radius: 20,
        ),
      )).toList(),
    );
  }
}
