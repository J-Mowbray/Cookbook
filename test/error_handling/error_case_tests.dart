// File: test/error_handling/error_case_tests.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cookbook/models/recipe.dart';
import 'package:cookbook/models/recipe_category.dart';
import 'package:cookbook/screens/recipe_list_screen.dart';
import 'package:cookbook/screens/recipe_detail_screen.dart';
import 'package:cookbook/services/recipe_service.dart';
import '../mocks/mock_recipe_repository.dart';

// Custom mock service for error testing that throws exceptions
class ErrorThrowingRecipeService extends ChangeNotifier implements RecipeService {
  final bool throwOnLoad;
  final bool throwOnGet;
  final bool throwOnAdd;
  final bool throwOnUpdate;
  final bool throwOnDelete;

  List<Recipe> _recipes = [];
  bool _isLoading = false;

  ErrorThrowingRecipeService({
    this.throwOnLoad = false,
    this.throwOnGet = false,
    this.throwOnAdd = false,
    this.throwOnUpdate = false,
    this.throwOnDelete = false,
  });

  @override
  List<Recipe> get recipes => _recipes;

  @override
  bool get isLoading => _isLoading;

  @override
  Future<void> loadRecipes() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 100)); // Simulate network delay

      if (throwOnLoad) {
        throw Exception('Failed to load recipes (simulated error)');
      }

      _recipes = [
        Recipe(
          id: '1',
          name: 'Test Recipe',
          description: 'Test Description',
          ingredients: 'Test Ingredients',
          instructions: 'Test Instructions',
          category: RecipeCategory.breakfast,
        ),
      ];
    } catch (e) {
      // Let the exception propagate but make sure to reset loading state
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  Recipe? getRecipeById(String id) {
    if (throwOnGet) {
      throw Exception('Failed to get recipe (simulated error)');
    }

    try {
      return _recipes.firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Recipe>> getRecipesByCategory(RecipeCategory category) async {
    if (throwOnGet) {
      throw Exception('Failed to get recipes by category (simulated error)');
    }

    if (category == RecipeCategory.all) {
      return _recipes;
    }
    return _recipes.where((recipe) => recipe.category == category).toList();
  }

  @override
  Future<void> addRecipe({
    required String name,
    required String description,
    required String ingredients,
    required String instructions,
    required RecipeCategory category,
  }) async {
    if (throwOnAdd) {
      throw Exception('Failed to add recipe (simulated error)');
    }

    final newRecipe = Recipe(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      ingredients: ingredients,
      instructions: instructions,
      category: category,
    );

    _recipes.add(newRecipe);
    notifyListeners();
  }

  @override
  Future<void> updateRecipe(Recipe updatedRecipe) async {
    if (throwOnUpdate) {
      throw Exception('Failed to update recipe (simulated error)');
    }

    final index = _recipes.indexWhere((recipe) => recipe.id == updatedRecipe.id);
    if (index != -1) {
      _recipes[index] = updatedRecipe;
      notifyListeners();
    }
  }

  @override
  Future<void> deleteRecipe(String id) async {
    if (throwOnDelete) {
      throw Exception('Failed to delete recipe (simulated error)');
    }

    _recipes.removeWhere((recipe) => recipe.id == id);
    notifyListeners();
  }
}

void main() {
  group('Error Case Tests', () {
    testWidgets('RecipeListScreen handles load error gracefully', (WidgetTester tester) async {
      // Create service that will throw on load
      final errorService = ErrorThrowingRecipeService(throwOnLoad: true);

      // Build widget
      await tester.pumpWidget(
        ChangeNotifierProvider<RecipeService>.value(
          value: errorService,
          child: MaterialApp(
            home: RecipeListScreen(
              category: RecipeCategory.all,
              title: 'Test',
            ),
          ),
        ),
      );

      // Wait for load to start
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for error to occur and UI to update
      await tester.pumpAndSettle();

      // Should show error UI (this depends on your implementation)
      // If you don't have specific error UI, it might show the empty state
      expect(find.text('No recipes in this category yet!'), findsOneWidget);

      // CircularProgressIndicator should be gone
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('RecipeService handles repository error gracefully', (WidgetTester tester) async {
      // Create service with error repository
      final errorRepo = MockRecipeRepository.withError();
      final recipeService = RecipeService(repository: errorRepo);

      // Wrap in a FutureBuilder to simulate usage in a widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FutureBuilder<void>(
              future: recipeService.loadRecipes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                return ListView.builder(
                  itemCount: recipeService.recipes.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(recipeService.recipes[index].name),
                    );
                  },
                );
              },
            ),
          ),
        ),
      );

      // Wait for the future to complete
      await tester.pumpAndSettle();

      // Should display error message
      expect(find.textContaining('Error:'), findsOneWidget);

      // Verify service state is handled properly
      expect(recipeService.isLoading, isFalse);
      expect(recipeService.recipes, isEmpty);
    });

    testWidgets('Recipe detail screen handles recipe lookup errors', (WidgetTester tester) async {
      // Create a service that throws on getRecipeById
      final errorService = ErrorThrowingRecipeService(throwOnGet: true);
      errorService._recipes = [
        Recipe(
          id: '1',
          name: 'Test Recipe',
          description: 'Test Description',
          ingredients: 'Test Ingredients',
          instructions: 'Test Instructions',
          category: RecipeCategory.breakfast,
        ),
      ];

      // We need a valid recipe to pass to the detail screen initially
      final recipe = Recipe(
        id: '1',
        name: 'Test Recipe',
        description: 'Test Description',
        ingredients: 'Test Ingredients',
        instructions: 'Test Instructions',
        category: RecipeCategory.breakfast,
      );

      // Build widget - it should throw when trying to access the recipe within the screen
      await tester.pumpWidget(
        ChangeNotifierProvider<RecipeService>.value(
          value: errorService,
          child: MaterialApp(
            home: RecipeDetailScreen(recipe: recipe),
            builder: (context, child) {
              // Add error handling at the app level
              return Material(
                child: Builder(
                  builder: (context) {
                    // Use try-catch to catch any errors during build
                    try {
                      return child!;
                    } catch (e) {
                      return Center(child: Text('Error: $e'));
                    }
                  },
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // The specific behavior here depends on how your app handles errors.
      // If your RecipeDetailScreen has internal error handling, test that.
      // Otherwise, we're relying on the error handler in the builder above.
      expect(find.textContaining('Error:'), findsWidgets);
    });

    testWidgets('Recipe delete error is handled gracefully', (WidgetTester tester) async {
      // Create a service that throws on delete
      final errorService = ErrorThrowingRecipeService(throwOnDelete: true);
      errorService._recipes = [
        Recipe(
          id: '1',
          name: 'Test Recipe',
          description: 'Test Description',
          ingredients: 'Test Ingredients',
          instructions: 'Test Instructions',
          category: RecipeCategory.breakfast,
        ),
      ];

      final recipe = errorService._recipes.first;

      // Build widget
      await tester.pumpWidget(
        ChangeNotifierProvider<RecipeService>.value(
          value: errorService,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return TextButton(
                    onPressed: () async {
                      try {
                        await errorService.deleteRecipe(recipe.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Recipe deleted')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                    child: const Text('Delete Recipe'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Tap the delete button
      await tester.tap(find.text('Delete Recipe'));
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.textContaining('Error:'), findsOneWidget);

      // Recipe should still exist in the service
      expect(errorService.recipes.length, 1);
    });
  });
}