// File: test/services/recipe_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cookbook/models/recipe.dart';
import 'package:cookbook/models/recipe_category.dart';
import 'package:cookbook/services/recipe_service.dart';
import '../mocks/mock_recipe_repository.dart';

void main() {
  group('RecipeService Tests', () {
    late RecipeService recipeService;
    late MockRecipeRepository mockRepository;

    setUp(() {
      // Create a fresh repository and service before each test
      mockRepository = MockRecipeRepository();
      recipeService = RecipeService(repository: mockRepository);
    });

    test('loadRecipes loads recipes from repository', () async {
      // Act
      await recipeService.loadRecipes();

      // Assert
      expect(recipeService.recipes.length, 4);
      expect(recipeService.isLoading, false);
    });

    test('loadRecipes sets isLoading correctly', () async {
      // Initial state
      expect(recipeService.isLoading, false);

      // Create a delayed repository to test loading state
      final delayedRepo = _DelayedMockRecipeRepository();
      final delayedService = RecipeService(repository: delayedRepo);

      // Start loading
      final loadFuture = delayedService.loadRecipes();

      // Should be loading now
      expect(delayedService.isLoading, true);

      // Wait for completion
      await loadFuture;

      // Should be done loading
      expect(delayedService.isLoading, false);
    });

    test('loadRecipes handles errors gracefully', () async {
      // Arrange
      final errorRepo = MockRecipeRepository.withError();
      final errorService = RecipeService(repository: errorRepo);

      // Act
      await errorService.loadRecipes();

      // Assert
      expect(errorService.recipes, isEmpty);
      expect(errorService.isLoading, false);
    });

    test('getRecipeById returns correct recipe', () async {
      // Arrange
      await recipeService.loadRecipes();

      // Act
      final recipe = recipeService.getRecipeById('2');

      // Assert
      expect(recipe, isNotNull);
      expect(recipe!.id, '2');
      expect(recipe.name, 'Sandwich');
    });

    test('getRecipeById returns null for non-existent ID', () async {
      // Arrange
      await recipeService.loadRecipes();

      // Act
      final recipe = recipeService.getRecipeById('non-existent');

      // Assert
      expect(recipe, isNull);
    });

    test('getRecipesByCategory filters correctly', () async {
      // Arrange
      await recipeService.loadRecipes();

      // Act
      final breakfastRecipes = await recipeService.getRecipesByCategory(RecipeCategory.breakfast);
      final lunchRecipes = await recipeService.getRecipesByCategory(RecipeCategory.lunch);
      final allRecipes = await recipeService.getRecipesByCategory(RecipeCategory.all);

      // Assert
      expect(breakfastRecipes.length, 1);
      expect(breakfastRecipes.first.name, 'Pancakes');

      expect(lunchRecipes.length, 1);
      expect(lunchRecipes.first.name, 'Sandwich');

      expect(allRecipes.length, 4);
    });

    test('addRecipe adds recipe to repository and updates list', () async {
      // Arrange
      await recipeService.loadRecipes();

      // Act
      await recipeService.addRecipe(
        name: 'New Recipe',
        description: 'Description',
        ingredients: 'Ingredients',
        instructions: 'Instructions',
        category: RecipeCategory.dinner,
      );

      // Assert
      // Instead of checking for a specific length, check that the new recipe is present
      final newRecipe = recipeService.recipes.firstWhere(
            (recipe) => recipe.name == 'New Recipe',
        orElse: () => throw Exception('Added recipe not found'),
      );

      expect(newRecipe.name, 'New Recipe');
      expect(newRecipe.description, 'Description');
      expect(newRecipe.ingredients, 'Ingredients');
      expect(newRecipe.instructions, 'Instructions');
      expect(newRecipe.category, RecipeCategory.dinner);
    });

    test('updateRecipe updates existing recipe', () async {
      // Arrange
      await recipeService.loadRecipes();
      final recipeToUpdate = recipeService.recipes.first;
      final updatedRecipe = recipeToUpdate.copyWith(
        name: 'Updated Name',
        description: 'Updated Description',
      );

      // Act
      await recipeService.updateRecipe(updatedRecipe);

      // Assert
      final retrievedRecipe = recipeService.getRecipeById(recipeToUpdate.id);
      expect(retrievedRecipe, isNotNull);
      expect(retrievedRecipe!.name, 'Updated Name');
      expect(retrievedRecipe.description, 'Updated Description');
      // Other properties should remain unchanged
      expect(retrievedRecipe.ingredients, recipeToUpdate.ingredients);
    });

    test('deleteRecipe removes recipe', () async {
      // Arrange
      await recipeService.loadRecipes();
      final initialLength = recipeService.recipes.length;
      final recipeIdToDelete = recipeService.recipes.first.id;

      // Act
      await recipeService.deleteRecipe(recipeIdToDelete);

      // Assert
      expect(recipeService.recipes.length, initialLength - 1);
      expect(recipeService.getRecipeById(recipeIdToDelete), isNull);
    });
  });
}

// Helper class for testing loading state
class _DelayedMockRecipeRepository extends MockRecipeRepository {
  @override
  Future<List<Recipe>> getAllRecipes() async {
    // Add delay to simulate network request
    await Future.delayed(const Duration(milliseconds: 100));
    return super.getAllRecipes();
  }
}