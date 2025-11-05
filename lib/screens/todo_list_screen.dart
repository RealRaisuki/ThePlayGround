
import 'package:alttask/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../category_provider.dart';
import '../theme_provider.dart';
import 'todo_item.dart';
import '../services/storage_service.dart';
import '../widgets/date_time_picker.dart';
import '../widgets/task_list_item.dart';
import '../user/users.dart';
import 'category_management_screen.dart';

class TodoListScreen extends StatefulWidget {
  final User user;
  final ThemeProvider themeProvider;

  const TodoListScreen({
    super.key,
    required this.user,
    required this.themeProvider,
  });

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late final StorageService _storageService;
  final List<TodoItem> _todoItems = [];
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final Map<String, TextEditingController> _editingControllers = {};

  String? _editingTaskId;
  bool _isSearching = false;
  String _searchQuery = '';

  List<TodoItem>? _cachedSortedTasks;
  String? _cachedSearchQuery;
  List<TodoItem>? _cachedFilteredTasks;

  @override
  void initState() {
    super.initState();
    _storageService = StorageService(userId: widget.user.id);
    _loadTasks();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _cachedFilteredTasks = null;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    for (var controller in _editingControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadTasks() async {
    try {
      final tasks = await _storageService.loadTasks();
      setState(() {
        _todoItems.clear();
        _todoItems.addAll(tasks);
        _invalidateCache();
      });
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Failed to load tasks');
      }
    }
  }

  Future<void> _saveTasks() async {
    try {
      await _storageService.saveTasks(_todoItems);
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Failed to save tasks');
      }
    }
  }

  List<TodoItem> get _sortedTasks {
    if (_cachedSortedTasks != null) {
      return _cachedSortedTasks!;}

    final now = DateTime.now();
    final List<TodoItem> dueTasks = [];
    final List<TodoItem> todayTasks = [];
    final List<TodoItem> tomorrowTasks = [];
    final List<TodoItem> upcomingTasks = [];
    final List<TodoItem> noDateTasks = [];
    final List<TodoItem> completedTasks = [];

    for (final task in _todoItems) {
      if (task.isCompleted) {
        completedTasks.add(task);
        continue;
      }

      if (task.dueDate == null) {
        noDateTasks.add(task);
        continue;
      }

      if (task.isOverdue) {
        dueTasks.add(task);
      } else {
        final taskDate = DateTime(
          task.dueDate!.year,
          task.dueDate!.month,
          task.dueDate!.day,
        );
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));

        if (taskDate == today) {
          todayTasks.add(task);
        } else if (taskDate == tomorrow) {
          tomorrowTasks.add(task);
        } else {
          upcomingTasks.add(task);
        }
      }
    }

    int sortByDueDate(TodoItem a, TodoItem b) {
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    }

    dueTasks.sort(sortByDueDate);
    todayTasks.sort(sortByDueDate);
    tomorrowTasks.sort(sortByDueDate);
    upcomingTasks.sort(sortByDueDate);

    _cachedSortedTasks = [
      ...dueTasks,
      ...todayTasks,
      ...tomorrowTasks,
      ...upcomingTasks,
      ...noDateTasks,
      ...completedTasks,
    ];

    return _cachedSortedTasks!;
  }

  List<TodoItem> get _filteredTasks {
    if (_searchQuery.isEmpty) return _sortedTasks;

    if (_cachedFilteredTasks != null && _cachedSearchQuery == _searchQuery) {
      return _cachedFilteredTasks!;}

    _cachedSearchQuery = _searchQuery;
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    _cachedFilteredTasks = _sortedTasks
        .where(
          (task) =>
              task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              categoryProvider.categories
                  .firstWhere((c) => c.id == task.categoryId)
                  .name
                  .toLowerCase()
                  .contains(
                    _searchQuery.toLowerCase(),
                  ),
        )
        .toList();

    return _cachedFilteredTasks!;
  }

  void _invalidateCache() {
    _cachedSortedTasks = null;
    _cachedFilteredTasks = null;
    _cachedSearchQuery = null;
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildStatistics() {
    final totalTasks = _todoItems.length;
    final completedTasks = _todoItems.where((task) => task.isCompleted).length;
    final dueTasks = _todoItems.where((task) => task.isOverdue && !task.isCompleted).length;
    final completionRate = totalTasks > 0 ? completedTasks / totalTasks : 0;

    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: const Duration(milliseconds: 500),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Productivity Overview',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        'Total',
                        totalTasks.toString(),
                        Icons.list,
                        Colors.blue,
                      ),
                      _buildStatItem(
                        'Done',
                        completedTasks.toString(),
                        Icons.check_circle,
                        Colors.green,
                      ),
                      _buildStatItem(
                        'Due',
                        dueTasks.toString(),
                        Icons.warning,
                        Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: completionRate.toDouble(),
                    backgroundColor: Colors.grey[300],
                    color: completionRate > 0.7 ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(completionRate * 100).toStringAsFixed(1)}% Complete',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.checklist, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'No tasks yet!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tap the + button to add your first task',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInfo(List<TodoItem> filteredTasks) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Found ${filteredTasks.length} task${filteredTasks.length == 1 ? '' : 's'} for "$_searchQuery"',
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildDivider(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey[400])),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey[400])),
        ],
      ),
    );
  }

  String _getTaskGroup(TodoItem task) {
    if (task.isCompleted) {
      return 'Completed';
    }
    if (task.dueDate == null) {
      return 'No Date';
    }
    if (task.isOverdue) {
      return 'Due';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);

    if (taskDate == today) {
      return 'Today';
    }
    if (taskDate == tomorrow) {
      return 'Tomorrow';
    }
    return 'Upcoming';
  }

  Widget _buildTaskList(List<TodoItem> filteredTasks) {
    if (filteredTasks.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No tasks found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            Text(
              'Try different search terms',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          final item = filteredTasks[index];
          _editingControllers.putIfAbsent(
            item.id,
            () => TextEditingController(text: item.title),
          );

          final currentGroup = _getTaskGroup(item);
          final previousGroup = index > 0 ? _getTaskGroup(filteredTasks[index - 1]) : null;

          final bool showDivider = index == 0 || currentGroup != previousGroup;

          return Column(
            children: [
              if (showDivider) _buildDivider(currentGroup),
              TaskListItem(
                item: item,
                isEditing: _editingTaskId == item.id,
                onEdit: () => _startEditing(item.id),
                onSave: () => _saveEditing(item.id),
                onCancel: _cancelEditing,
                onDelete: () => _deleteTodoItem(item.id),
                onCompletionChanged: (isCompleted) {
                  _toggleTodoItem(item.id, isCompleted ?? false);
                },
                titleController: _editingControllers[item.id]!,
                onDateChanged: (newDate) {
                  _updateTask(item.id, dueDate: newDate);
                },
                onCategoryChanged: (newCategoryId) {
                  if (newCategoryId != null) {
                    _updateTask(item.id, categoryId: newCategoryId);
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final themeProvider = widget.themeProvider;
    final filteredTasks = _filteredTasks;

    final isCurrentlyDark = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  border: InputBorder.none,
                  hintStyle: const TextStyle(color: Colors.white70),
                  icon: const Icon(Icons.search, color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                autofocus: true,
              )
            : Text('Welcome ${widget.user.username}'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                  _cachedFilteredTasks = null;
                }
              });
            },
            tooltip: 'Search tasks',
          ),
          IconButton(
            icon: Icon(isCurrentlyDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeProvider.toggleTheme();
            },
            tooltip: 'Toggle Theme',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                authService.signOut();
              } else if (value == 'edit_categories') {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CategoryManagementScreen()));
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit_categories',
                child: Text('Edit Categories'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: _todoItems.isEmpty && _searchQuery.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                if (_todoItems.isNotEmpty && _searchQuery.isEmpty) _buildStatistics(),
                if (_searchQuery.isNotEmpty) _buildSearchInfo(filteredTasks),
                Expanded(child: _buildTaskList(filteredTasks)),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _displayAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addTodoItem(String task, DateTime? dueDate, String categoryId) {
    if (task.trim().isNotEmpty) {
      setState(() {
        final newItem = TodoItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: task,
          isCompleted: false,
          dueDate: dueDate,
          categoryId: categoryId,
        );
        _todoItems.add(newItem);
        _editingControllers[newItem.id] = TextEditingController(
          text: newItem.title,
        );
        _invalidateCache();
      });
      _saveTasks();
    }
  }

  void _updateTask(
    String taskId, {
    String? title,
    DateTime? dueDate,
    String? categoryId,
    bool? isCompleted,
  }) {
    setState(() {
      final taskIndex = _todoItems.indexWhere((item) => item.id == taskId);
      if (taskIndex != -1) {
        _todoItems[taskIndex] = _todoItems[taskIndex].copyWith(
          title: title,
          dueDate: dueDate,
          categoryId: categoryId,
          isCompleted: isCompleted,
        );
        _invalidateCache();
      }
    });
    _saveTasks();
  }

  void _startEditing(String taskId) {
    setState(() {
      _editingTaskId = taskId;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingTaskId = null;
    });
  }

  void _saveEditing(String taskId) {
    final newTitle = _editingControllers[taskId]!.text;
    _updateTask(taskId, title: newTitle);
    setState(() {
      _editingTaskId = null;
    });
  }

  void _deleteTodoItem(String taskId) {
    setState(() {
      _todoItems.removeWhere((item) => item.id == taskId);
      _editingControllers.remove(taskId)?.dispose();
      _invalidateCache();
    });
    _saveTasks();
  }

  void _toggleTodoItem(String taskId, bool isCompleted) {
    _updateTask(taskId, isCompleted: isCompleted);
  }

  void _displayAddDialog() {
    final textController = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    var selectedCategory = categoryProvider.categories.first;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add a new task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: textController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your task...',
                        border: OutlineInputBorder(),
                      ),
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Category:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: categoryProvider.categories.map((category) {
                            return ChoiceChip(
                              label: Text(category.name),
                              selected: selectedCategory.id == category.id,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    selectedCategory = category;
                                  });
                                }
                              },
                              backgroundColor: category.color.withAlpha(25),
                              selectedColor: category.color.withAlpha(76),
                              labelStyle: TextStyle(
                                color: selectedCategory.id == category.id ? category.color : Colors.grey[700],
                                fontWeight: selectedCategory.id == category.id ? FontWeight.bold : FontWeight.normal,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DateTimePicker(
                      selectedDate: selectedDate,
                      selectedTime: selectedTime,
                      onDateSelected: (date) => setState(() => selectedDate = date),
                      onTimeSelected: (time) => setState(() => selectedTime = time),
                      onClearSelection: () => setState(() {
                        selectedDate = null;
                        selectedTime = null;
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (textController.text.trim().isNotEmpty) {
                      DateTime? combinedDateTime;
                      if (selectedDate != null) {
                        combinedDateTime = DateTime(
                          selectedDate!.year,
                          selectedDate!.month,
                          selectedDate!.day,
                          selectedTime?.hour ?? 0,
                          selectedTime?.minute ?? 0,
                        );
                      }
                      _addTodoItem(
                        textController.text,
                        combinedDateTime,
                        selectedCategory.id,
                      );
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
