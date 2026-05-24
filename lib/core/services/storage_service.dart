import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_storage_flutter/features/todo/models/task.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  static const String _todosKey = 'todos';
  static const String _isDarkModeKey = 'isDarkMode';
  static const String _lastSaveTimeKey = 'lastSaveTime';
  static const String _totalTasksKey = 'totalTasksCreated';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveTasks(List<Task> tasks) async {
    if (_prefs == null) return;

    final encoded = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await _prefs!.setString(_todosKey, encoded);
    await _prefs!.setString(_lastSaveTimeKey, DateTime.now().toIso8601String());
  }

  List<Task> loadTasks() {
    if (_prefs == null) return [];

    final raw = _prefs!.getString(_todosKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveThemeMode(bool isDarkMode) async {
    await _prefs?.setBool(_isDarkModeKey, isDarkMode);
  }

  bool loadThemeMode() {
    return _prefs?.getBool(_isDarkModeKey) ?? false;
  }

  String? getLastSaveTime() {
    final raw = _prefs?.getString(_lastSaveTimeKey);
    if (raw == null) return null;

    try {
      final dt = DateTime.parse(raw);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return null;
    }
  }

  Future<void> incrementTotalTasks() async {
    if (_prefs == null) return;
    final current = _prefs!.getInt(_totalTasksKey) ?? 0;
    await _prefs!.setInt(_totalTasksKey, current + 1);
  }

  int getTotalTasksCreated() {
    return _prefs?.getInt(_totalTasksKey) ?? 0;
  }
}
