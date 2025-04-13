// File: test/services/advanced_recipe_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cookbook/models/recipe.dart';
import 'package:cookbook/models/recipe_category.dart';
import 'package:cookbook/services/recipe_service.dart';
import '../mocks/mock_recipe_repository.dart';

void main() {
  group('Advanced RecipeService Tests', () {
    late RecipeService recipeService;
    late MockRecipeRepository mockRepository;

    setUp(() {
      mockRepository = MockRecipeRepository();
      recipeService = RecipeService(repository: mockRepository);
    });

    test('handles concurrent operations correctly', () async {
      // Initialize service
      await recipeService.loadRecipes();
      final initialCount = recipeService.recipes.length;

      // Start multiple operations concurrently
      final futures = await Future.wait([
        // Add a recipe
        recipeService.addRecipe(
          name: 'Concurrent Recipe 1',
          description: 'Description 1',
          ingredients: 'Ingredients 1',
          instructions: 'Instructions 1',
          category: RecipeCategory.breakfast,
        ),

        // Add another recipe
        recipeService.addRecipe(
          name: 'Concurrent Recipe 2',
          description: 'Description 2',
          ingredients: 'Ingredients 2',
          instructions: 'Instructions 2',
          category: RecipeCategory.lunch,
        ),

        // Update an existing recipe (the first one)
        recipeService.updateRecipe(
          recipeService.recipes.first.copyWith(
            name: 'Updated During Concurrency',
            description: 'Updated description',
          ),
        ),
      ]);

      // Verify results
      expect(recipeService.recipes.length, initialCount + 2);

      // Check that both new recipes were added
      expect(
        recipeService.recipes.any((r) => r.name == 'Concurrent Recipe 1'),
        isTrue,
      );
      expect(
        recipeService.recipes.any((r) => r.name == 'Concurrent Recipe 2'),
        isTrue,
      );

      // Check that the update happened
      final updatedRecipe = recipeService.getRecipeById(
        recipeService.recipes.first.id,
      );
      expect(updatedRecipe?.name, 'Updated During Concurrency');
    });

    test('handles empty state and then adding first recipe', () async {
      // Start with empty repository
      final emptyRepo = MockRecipeRepository.empty();
      final emptyService = RecipeService(repository: emptyRepo);

      // Load recipes (should be empty)
      await emptyService.loadRecipes();
      expect(emptyService.recipes, isEmpty);

      // Add the first recipe
      await emptyService.addRecipe(
        name: 'First Recipe',
        description: 'First Description',
        ingredients: 'First Ingredients',
        instructions: 'First Instructions',
        category: RecipeCategory.dinner,
      );

      // Verify recipe was added
      expect(emptyService.recipes.length, 1);
      expect(emptyService.recipes.first.name, 'First Recipe');
    });

    test('search functionality finds recipes by name', () async {
      // This test assumes your RecipeService has or will have a search method
      // If it doesn't exist yet, consider this a specification for future implementation

      // Load recipes
      await recipeService.loadRecipes();

      // Add some recipes with searchable names
      await recipeService.addRecipe(
        name: 'Chocolate Cake',
        description: 'Delicious chocolate cake',
        ingredients: 'Chocolate, flour, sugar',
        instructions: 'Mix and bake',
        category: RecipeCategory.dessert,
      );

      await recipeService.addRecipe(
        name: 'Chocolate Chip Cookies',
        description: 'Classic cookies',
        ingredients: 'Chocolate chips, flour, sugar',
        instructions: 'Mix and bake',
        category: RecipeCategory.dessert,
      );

      await recipeService.addRecipe(
        name: 'Vanilla Ice Cream',
        description: 'Creamy vanilla ice cream',
        ingredients: 'Cream, sugar, vanilla',
        instructions: 'Mix and freeze',
        category: RecipeCategory.dessert,
      );

      // If you have a search method, uncomment and use this:
      /*
      // Search for chocolate recipes
      final chocolateRecipes = await recipeService.searchRecipes('chocolate');
      expect(chocolateRecipes.length, 2);
      expect(
        chocolateRecipes.every((r) => r.name.toLowerCase().contains('chocolate')),
        isTrue,
      );

      // Search for vanilla recipes
      final vanillaRecipes = await recipeService.searchRecipes('vanilla');
      expect(vanillaRecipes.length, 1);
      expect(vanillaRecipes.first.name, 'Vanilla Ice Cream');

      // Search with no matches
      final noMatchRecipes = await recipeService.searchRecipes('pizza');
      expect(noMatchRecipes, isEmpty);
      */

      // Without a search method, we can test the concept using list filtering:
      final chocolateRecipes = recipeService.recipes
          .where((r) => r.name.toLowerCase().contains('chocolate'))
          .toList();
      expect(chocolateRecipes.length, 2);

      final vanillaRecipes = recipeService.recipes
          .where((r) => r.name.toLowerCase().contains('vanilla'))
          .toList();
      expect(vanillaRecipes.length, 1);
      expect(vanillaRecipes.first.name, 'Vanilla Ice Cream');
    });

    test('recipe with very long content is handled correctly', () async {
      // Create a recipe with extremely long content
      final longRecipe = Recipe(
        id: 'long-content',
        name: 'Recipe With Extremely Long Name That Would Challenge Any UI Implementation',
        description: 'This description is intentionally very long and verbose to test the robustness of the system when dealing with large amounts of text data. It contains multiple sentences and goes on for quite a while to ensure that it exceeds typical text field sizes in most UIs.',
        ingredients: 'Ingredient 1 with detailed specification, Ingredient 2 with even more detailed specification and notes about where to find it, Ingredient 3 with preparation instructions included right in the ingredient list, Ingredient 4 with alternatives listed in case it\'s not available, Ingredient 5 with measurement conversions, Ingredient 6 with brand recommendations, Ingredient 7 with storage instructions, Ingredient 8 with nutritional information, Ingredient 9 with allergen warnings, Ingredient 10 with price estimates',
        instructions: '1. This first step is extremely detailed and includes multiple substeps and notes about what to watch for during the process. It also includes troubleshooting advice if things don\'t go as expected.\n2. The second step is equally verbose and includes references to equipment that might not be available in every kitchen, with alternatives suggested.\n3. Step three includes timing information and visual cues to look for.\n4. Step four discusses variations for dietary restrictions.\n5. Step five contains serving suggestions and pairing recommendations.\n6. Step six includes storage instructions for leftovers.\n7. Step seven has notes about how to reheat if making ahead of time.\n8. Step eight contains nutritional information.\n9. Step nine has suggestions for accompaniments.\n10. Step ten is a long conclusion with final tips.',
        category: RecipeCategory.dinner,
      );

      // Add this recipe to the service
      await recipeService.loadRecipes();
      await recipeService.addRecipe(
        name: longRecipe.name,
        description: longRecipe.description,
        ingredients: longRecipe.ingredients,
        instructions: longRecipe.instructions,
        category: longRecipe.category,
      );

      // Verify the recipe can be retrieved and its content is intact
      final retrievedRecipes = recipeService.recipes
          .where((r) => r.name.contains('Extremely Long Name'))
          .toList();

      expect(retrievedRecipes.length, 1);
      final retrievedRecipe = retrievedRecipes.first;

      // Verify content lengths
      expect(retrievedRecipe.name.length, longRecipe.name.length);
      expect(retrievedRecipe.description.length, longRecipe.description.length);
      expect(retrievedRecipe.ingredients.length, longRecipe.ingredients.length);
      expect(retrievedRecipe.instructions.length, longRecipe.instructions.length);
    });
  });
}