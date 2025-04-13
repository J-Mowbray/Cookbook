import 'package:flutter_test/flutter_test.dart';
import 'package:cookbook/models/recipe.dart';
import 'package:cookbook/models/recipe_category.dart';

void main() {
  group('Recipe Model Tests', () {
    test('constructor creates recipe with correct properties', () {
      // Arrange & Act
      final recipe = Recipe(
        id: '123',
        name: 'Test Recipe',
        description: 'Test Description',
        ingredients: 'Test Ingredients',
        instructions: 'Test Instructions',
        category: RecipeCategory.dinner,
      );

      // Assert
      expect(recipe.id, '123');
      expect(recipe.name, 'Test Recipe');
      expect(recipe.description, 'Test Description');
      expect(recipe.ingredients, 'Test Ingredients');
      expect(recipe.instructions, 'Test Instructions');
      expect(recipe.category, RecipeCategory.dinner);
    });

    test('fromMap creates recipe correctly', () {
      // Arrange
      final Map<String, dynamic> recipeMap = {
        'id': '123',
        'name': 'Test Recipe',
        'description': 'Test Description',
        'ingredients': 'Test Ingredients',
        'instructions': 'Test Instructions',
        'category': 'dinner',
      };

      // Act
      final recipe = Recipe.fromMap(recipeMap);

      // Assert
      expect(recipe.id, '123');
      expect(recipe.name, 'Test Recipe');
      expect(recipe.description, 'Test Description');
      expect(recipe.ingredients, 'Test Ingredients');
      expect(recipe.instructions, 'Test Instructions');
      expect(recipe.category, RecipeCategory.dinner);
    });

    test('toMap converts recipe correctly', () {
      // Arrange
      final recipe = Recipe(
        id: '123',
        name: 'Test Recipe',
        description: 'Test Description',
        ingredients: 'Test Ingredients',
        instructions: 'Test Instructions',
        category: RecipeCategory.dinner,
      );

      // Act
      final recipeMap = recipe.toMap();

      // Assert
      expect(recipeMap['id'], '123');
      expect(recipeMap['name'], 'Test Recipe');
      expect(recipeMap['description'], 'Test Description');
      expect(recipeMap['ingredients'], 'Test Ingredients');
      expect(recipeMap['instructions'], 'Test Instructions');
      expect(recipeMap['category'], 'dinner');
    });

    test('fromMap handles missing values with defaults', () {
      // Arrange
      final Map<String, dynamic> partialMap = {
        'id': '123',
        // Missing other fields
      };

      // Act
      final recipe = Recipe.fromMap(partialMap);

      // Assert
      expect(recipe.id, '123');
      expect(recipe.name, '');
      expect(recipe.description, '');
      expect(recipe.ingredients, '');
      expect(recipe.instructions, '');
      expect(recipe.category, RecipeCategory.all);
    });

    test('copyWith creates new instance with updated values', () {
      // Arrange
      final original = Recipe(
        id: '123',
        name: 'Original Name',
        description: 'Original Description',
        ingredients: 'Original Ingredients',
        instructions: 'Original Instructions',
        category: RecipeCategory.dinner,
      );

      // Act
      final updated = original.copyWith(
        name: 'Updated Name',
        category: RecipeCategory.breakfast,
      );

      // Assert
      // Check updated fields
      expect(updated.name, 'Updated Name');
      expect(updated.category, RecipeCategory.breakfast);

      // Check unmodified fields remained the same
      expect(updated.id, '123');
      expect(updated.description, 'Original Description');
      expect(updated.ingredients, 'Original Ingredients');
      expect(updated.instructions, 'Original Instructions');

      // Verify original not modified
      expect(original.name, 'Original Name');
      expect(original.category, RecipeCategory.dinner);
    });
  });
}