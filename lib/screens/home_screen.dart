import 'package:flutter/material.dart';
import '../models/recipe_category.dart';
import 'recipe_list_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function onThemeToggle;

  const HomeScreen({Key? key, required this.onThemeToggle}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Define the category-based screens
  final List<Widget> _screenOptions = [];
  final List<String> _titles = ['All Recipes', 'Breakfast', 'Lunch', 'Dinner', 'Dessert'];
  final List<RecipeCategory> _categories = [
    RecipeCategory.all,
    RecipeCategory.breakfast,
    RecipeCategory.lunch,
    RecipeCategory.dinner,
    RecipeCategory.dessert
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the screens
    for (int i = 0; i < _categories.length; i++) {
      _screenOptions.add(
        RecipeListScreen(
          category: _categories[i],
          title: _titles[i],
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
            key: const Key('theme_toggle_button'), // Add this key
            icon: Icon(
              brightness == Brightness.dark
                  ? Icons.wb_sunny_outlined
                  : Icons.nightlight_round,
              semanticLabel: 'Toggle theme',
            ),
            onPressed: () => widget.onThemeToggle(),
            tooltip: 'Toggle theme',
          ),
        ],
      ),
      body: _screenOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Needed for 4+ items
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'All',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.breakfast_dining),
            label: 'Breakfast',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lunch_dining),
            label: 'Lunch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dinner_dining),
            label: 'Dinner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cake),
            label: 'Dessert',
          ),
        ],
      ),
    );
  }
}