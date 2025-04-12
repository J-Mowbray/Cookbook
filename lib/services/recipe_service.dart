// services/recipe_service.dart
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/recipe.dart';
import '../models/recipe_category.dart';
import '../repositories/recipe_repository.dart';

// Service that handles business logic for recipes
class RecipeService with ChangeNotifier {
  final RecipeRepository _repository;
  List<Recipe> _recipes = [];
  bool _isLoading = false;

  RecipeService({RecipeRepository? repository})
      : _repository = repository ?? LocalRecipeRepository.instance;

  // Getters
  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;

  // Initialize and load recipes
  Future<void> loadRecipes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _recipes = await _repository.getAllRecipes();
    } catch (e) {
      print('Error loading recipes: $e');
      _recipes = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Get recipes by category
  Future<List<Recipe>> getRecipesByCategory(RecipeCategory category) async {
    if (category == RecipeCategory.all) {
      return _recipes;
    }
    return _recipes.where((recipe) => recipe.category == category).toList();
  }

  // Add a new recipe
  Future<void> addRecipe({
    required String name,
    required String description,
    required String ingredients,
    required String instructions,
    required RecipeCategory category,
  }) async {
    final newRecipe = Recipe(
      id: const Uuid().v4(), // Generate a unique ID
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

  // Update an existing recipe
  Future<void> updateRecipe(Recipe updatedRecipe) async {
    await _repository.updateRecipe(updatedRecipe);

    final index = _recipes.indexWhere((recipe) => recipe.id == updatedRecipe.id);
    if (index != -1) {
      _recipes[index] = updatedRecipe;
      notifyListeners();
    }
  }

  // Delete a recipe
  Future<void> deleteRecipe(String id) async {
    await _repository.deleteRecipe(id);
    _recipes.removeWhere((recipe) => recipe.id == id);
    notifyListeners();
  }

  // Get a recipe by ID
  Recipe? getRecipeById(String id) {
    try {
      return _recipes.firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      return null;
    }
  }
}