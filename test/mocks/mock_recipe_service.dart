// File: test/mocks/mock_recipe_service.dart
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:cookbook/models/recipe.dart';
import 'package:cookbook/models/recipe_category.dart';
import 'package:cookbook/services/recipe_service.dart';
import 'mock_recipe_repository.dart';

// A mock implementation of RecipeService for UI testing
class MockRecipeService extends ChangeNotifier implements RecipeService {
  final MockRecipeRepository _repository;
  List<Recipe> _recipes = [];
  bool _isLoading = false;

  MockRecipeService({MockRecipeRepository? repository})
      : _repository = repository ?? MockRecipeRepository();

  @override
  List<Recipe> get recipes => _recipes;

  @override
  bool get isLoading => _isLoading;

  @override
  Future<void> loadRecipes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _recipes = await _repository.getAllRecipes();
    } catch (e) {
      // In the mock, we'll just log the error rather than handling it
      debugPrint('Error in MockRecipeService.loadRecipes: $e');
      _recipes = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  Future<List<Recipe>> getRecipesByCategory(RecipeCategory category) async {
    return await _repository.getRecipesByCategory(category);
  }

  @override
  Recipe? getRecipeById(String id) {
    try {
      return _recipes.firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addRecipe({
    required String name,
    required String description,
    required String ingredients,
    required String instructions,
    required RecipeCategory category,
  }) async {
    final newRecipe = Recipe(
      id: const Uuid().v4(),
      name: name,
      description: description,
      ingredients: ingredients,
      instructions: instructions,
      category: category,
    );

    await _repository.addRecipe(newRecipe);
    _recipes.add(newRecipe);
    notifyListeners();
  }

  @override
  Future<void> updateRecipe(Recipe updatedRecipe) async {
    await _repository.updateRecipe(updatedRecipe);

    final index = _recipes.indexWhere((recipe) => recipe.id == updatedRecipe.id);
    if (index != -1) {
      _recipes[index] = updatedRecipe;
      notifyListeners();
    }
  }

  @override
  Future<void> deleteRecipe(String id) async {
    await _repository.deleteRecipe(id);
    _recipes.removeWhere((recipe) => recipe.id == id);
    notifyListeners();
  }

  // Helper methods for testing
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setRecipes(List<Recipe> recipes) {
    _recipes = recipes;
    notifyListeners();
  }
}