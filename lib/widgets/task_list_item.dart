import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:alttask/screens/todo_item.dart';

class TaskListItem extends StatelessWidget {
  final TodoItem item;
  final bool isEditing;
  final VoidCallback onEdit;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final VoidCallback onDelete;
  final Function(bool?) onCompletionChanged;
  final TextEditingController titleController;
  final Function(DateTime?) onDateChanged;
  final Function(TaskCategory?) onCategoryChanged;

  const TaskListItem({
    super.key,
    required this.item,
    required this.isEditing,
    required this.onEdit,
    required this.onSave,
    required this.onCancel,
    required this.onDelete,
    required this.onCompletionChanged,
    required this.titleController,
    required this.onDateChanged,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: isEditing ? _buildEditView(context) : _buildReadView(context),
      ),
    );
  }

  Widget _buildReadView(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Checkbox(
        value: item.isCompleted,
        onChanged: onCompletionChanged,
        shape: const CircleBorder(),
      ),
      title: Text(
        item.title,
        style: TextStyle(
          decoration: item.isCompleted ? TextDecoration.lineThrough : null,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(item.category.icon, size: 16, color: item.category.color),
                const SizedBox(width: 8.0),
                Text(
                  item.category.displayName,
                  style: TextStyle(
                    color: item.category.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (item.dueDate != null) const SizedBox(height: 4),
            if (item.dueDate != null)
              Text(
                'Due: ${DateFormat.yMMMd().add_jm().format(item.dueDate!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: item.isOverdue ? Colors.red : Colors.grey[600],
                  fontWeight: item.isOverdue
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
          ],
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: onEdit,
            tooltip: 'Edit task',
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
            tooltip: 'Delete task',
          ),
        ],
      ),
    );
  }

  Widget _buildEditView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: titleController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Task Title',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: item.dueDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (selectedDate == null) return;
                  if (!context.mounted) return;
                  final selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(
                      item.dueDate ?? DateTime.now(),
                    ),
                  );
                  if (selectedTime != null) {
                    final newDueDate = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );
                    onDateChanged(newDueDate);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Due Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    item.dueDate != null
                        ? DateFormat.yMMMd().add_jm().format(item.dueDate!)
                        : 'Not Set',
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () => onDateChanged(null),
              tooltip: 'Clear due date',
            ),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<TaskCategory>(
          initialValue: item.category,
          items: TaskCategory.values
              .map(
                (category) => DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Icon(category.icon, color: category.color),
                      const SizedBox(width: 8),
                      Text(category.displayName),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: onCategoryChanged,
          decoration: const InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: onCancel, child: const Text('Cancel')),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: onSave, child: const Text('Save')),
          ],
        ),
      ],
    );
  }
}
