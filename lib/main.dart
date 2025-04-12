import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'services/recipe_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => RecipeService(),
      child: const RecipeApp(),
    ),
  );
}

class RecipeApp extends StatefulWidget {
  const RecipeApp({super.key});

  @override
  State<RecipeApp> createState() => _RecipeAppState();
}

class _RecipeAppState extends State<RecipeApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    // Initialize recipe service
    Future.delayed(Duration.zero, () {
      Provider.of<RecipeService>(context, listen: false).loadRecipes();
    });
  }

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cookbook!',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(onThemeToggle: toggleTheme),
      debugShowCheckedModeBanner: false,
    );
  }
}