// File: test/mocks/mock_recipe_repository.dart
import 'package:cookbook/models/recipe.dart';
import 'package:cookbook/models/recipe_category.dart';
import 'package:cookbook/repositories/recipe_repository.dart';

class MockRecipeRepository implements RecipeRepository {
  final List<Recipe> _recipes;

  // Allow flexibility through constructor parameters for different test scenarios
  MockRecipeRepository({List<Recipe>? initialRecipes})
      : _recipes = initialRecipes ?? _createDefaultRecipes();

  // Helper to create a standard set of test recipes
  static List<Recipe> _createDefaultRecipes() {
    return [
      Recipe(
        id: '1',
        name: 'Pancakes',
        description: 'Fluffy breakfast pancakes',
        ingredients: 'Flour, Eggs, Milk, Sugar',
        instructions: '1. Mix ingredients\n2. Cook on griddle',
        category: RecipeCategory.breakfast,
      ),
      Recipe(
        id: '2',
        name: 'Sandwich',
        description: 'Classic lunch sandwich',
        ingredients: 'Bread, Cheese, Ham, Lettuce',
        instructions: '1. Layer ingredients\n2. Cut in half',
        category: RecipeCategory.lunch,
      ),
      Recipe(
        id: '3',
        name: 'Pasta',
        description: 'Simple pasta dinner',
        ingredients: 'Pasta, Sauce, Cheese',
        instructions: '1. Cook pasta\n2. Add sauce\n3. Sprinkle cheese',
        category: RecipeCategory.dinner,
      ),
      Recipe(
        id: '4',
        name: 'Chocolate Cake',
        description: 'Rich chocolate dessert',
        ingredients: 'Flour, Sugar, Cocoa, Eggs, Butter',
        instructions: '1. Mix dry ingredients\n2. Add wet ingredients\n3. Bake',
        category: RecipeCategory.dessert,
      ),
    ];
  }

  // Create an empty repository
  static MockRecipeRepository empty() {
    return MockRecipeRepository(initialRecipes: []);
  }

  // Create repository with error behavior
  static MockRecipeRepository withError() {
    return _ErrorMockRecipeRepository();
  }

  @override
  Future<List<Recipe>> getAllRecipes() async {
    return _recipes;
  }

  @override
  Future<List<Recipe>> getRecipesByCategory(RecipeCategory category) async {
    if (category == RecipeCategory.all) {
      return _recipes;
    }
    return _recipes.where((recipe) => recipe.category == category).toList();
  }

  @override
  Future<Recipe?> getRecipeById(String id) async {
    try {
      return _recipes.firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addRecipe(Recipe recipe) async {
    _recipes.add(recipe);
  }

  @override
  Future<void> updateRecipe(Recipe updatedRecipe) async {
    final index = _recipes.indexWhere((recipe) => recipe.id == updatedRecipe.id);
    if (index != -1) {
      _recipes[index] = updatedRecipe;
    }
  }

  @override
  Future<void> deleteRecipe(String id) async {
    _recipes.removeWhere((recipe) => recipe.id == id);
  }
}

// Repository that simulates errors for error handling tests
class _ErrorMockRecipeRepository extends MockRecipeRepository {
  @override
  Future<List<Recipe>> getAllRecipes() async {
    throw Exception('Failed to load recipes');
  }

  @override
  Future<List<Recipe>> getRecipesByCategory(RecipeCategory category) async {
    throw Exception('Failed to load recipes by category');
  }

  @override
  Future<Recipe?> getRecipeById(String id) async {
    throw Exception('Failed to get recipe');
  }

  @override
  Future<void> addRecipe(Recipe recipe) async {
    throw Exception('Failed to add recipe');
  }

  @override
  Future<void> updateRecipe(Recipe updatedRecipe) async {
    throw Exception('Failed to update recipe');
  }

  @override
  Future<void> deleteRecipe(String id) async {
    throw Exception('Failed to delete recipe');
  }
}