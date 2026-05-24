import 'package:flutter/material.dart';
import 'package:local_storage_flutter/core/services/storage_service.dart';
import 'package:local_storage_flutter/core/theme.dart';
import 'package:local_storage_flutter/features/todo/screens/todo_screen.dart';

final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  await storageService.init();

  isDarkModeNotifier.value = storageService.loadThemeMode();

  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          title: 'Flutter To-Do LR09',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const TodoScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
