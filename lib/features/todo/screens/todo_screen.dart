import 'package:flutter/material.dart';
import 'package:local_storage_flutter/core/services/storage_service.dart';
import 'package:local_storage_flutter/features/todo/models/task.dart';
import 'package:local_storage_flutter/features/todo/widgets/add_task_dialog.dart';
import 'package:local_storage_flutter/features/todo/widgets/category_filter.dart';
import 'package:local_storage_flutter/features/todo/widgets/empty_state.dart';
import 'package:local_storage_flutter/features/todo/widgets/statistics_bar.dart';
import 'package:local_storage_flutter/features/todo/widgets/task_tile.dart';
import 'package:local_storage_flutter/main.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<Task> _tasks = [];
  TaskCategory? _selectedFilterCategory;
  bool _isLoading = true;
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _tasks = _storageService.loadTasks();
      _isLoading = false;
    });
  }

  Future<void> _saveData(String message) async {
    await _storageService.saveTasks(_tasks);
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
    setState(() {});
  }

  void _addTask(Task task) async {
    setState(() {
      _tasks.insert(0, task);
    });
    await _storageService.incrementTotalTasks();
    _saveData('Task added successfully');
  }

  void _toggleTask(Task task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      setState(() {
        _tasks[index] = task.copyWith(isDone: !task.isDone);
      });
      _saveData('Task status updated');
    }
  }

  void _deleteTask(Task task) {
    setState(() {
      _tasks.removeWhere((t) => t.id == task.id);
    });
    _saveData('Task deleted');
  }

  void _clearCompleted() {
    setState(() {
      _tasks.removeWhere((t) => t.isDone);
    });
    _saveData('Completed tasks cleared');
  }

  void _toggleTheme() {
    final newMode = !isDarkModeNotifier.value;
    isDarkModeNotifier.value = newMode;
    _storageService.saveThemeMode(newMode);
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _selectedFilterCategory == null
        ? _tasks
        : _tasks.where((t) => t.category == _selectedFilterCategory).toList();

    final completedCount = _tasks.where((t) => t.isDone).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todo List'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder<bool>(
              valueListenable: isDarkModeNotifier,
              builder: (context, isDark, _) {
                return Icon(isDark ? Icons.light_mode : Icons.dark_mode);
              },
            ),
            onPressed: _toggleTheme,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                StatisticsBar(
                  completedCount: completedCount,
                  totalCount: _tasks.length,
                ),
                CategoryFilter(
                  selectedCategory: _selectedFilterCategory,
                  onCategorySelected: (category) {
                    setState(() {
                      _selectedFilterCategory = category;
                    });
                  },
                ),
                Expanded(
                  child: filteredTasks.isEmpty
                      ? const EmptyState()
                      : ListView.builder(
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = filteredTasks[index];
                            return TaskTile(
                              task: task,
                              onToggle: () => _toggleTask(task),
                              onDelete: () => _deleteTask(task),
                            );
                          },
                        ),
                ),
                _buildFooter(completedCount),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddTaskDialog(onAdd: _addTask),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFooter(int completedCount) {
    final lastSave = _storageService.getLastSaveTime();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('✅ Completed: $completedCount/${_tasks.length}'),
                if (lastSave != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 64.0),
                    child: Text(
                      '💾 Last saved: $lastSave',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
            if (completedCount > 0) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _clearCompleted,
                  child: const Text('Clear All Completed'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
