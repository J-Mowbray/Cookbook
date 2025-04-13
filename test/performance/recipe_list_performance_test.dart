// File: test/performance/recipe_list_performance_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cookbook/models/recipe.dart';
import 'package:cookbook/models/recipe_category.dart';
import 'package:cookbook/screens/recipe_list_screen.dart';
import 'package:cookbook/services/recipe_service.dart';
import '../mocks/mock_recipe_service.dart';

void main() {
  group('Recipe List Performance Tests', () {
    late MockRecipeService mockRecipeService;

    setUp(() {
      mockRecipeService = MockRecipeService();
    });

    // Helper function to generate many recipes
    List<Recipe> generateManyRecipes(int count) {
      return List.generate(count, (index) {
        final categoryIndex = index % 5; // Cycle through categories
        final category = RecipeCategory.values[categoryIndex >= 1 ? categoryIndex : 1]; // Avoid "all"

        return Recipe(
          id: 'perf-$index',
          name: 'Performance Test Recipe $index',
          description: 'Description for recipe $index',
          ingredients: 'Ingredients for recipe $index: ${List.generate(5, (i) => 'Ingredient ${index+i}').join(', ')}',
          instructions: List.generate(5, (step) => '${step+1}. Step ${step+1} for recipe $index').join('\n'),
          category: category,
        );
      });
    }

    Widget buildScreen(List<Recipe> recipes) {
      // Set the recipes in the mock service
      mockRecipeService.setRecipes(recipes);

      return ChangeNotifierProvider<RecipeService>.value(
        value: mockRecipeService,
        child: MaterialApp(
          home: RecipeListScreen(
            category: RecipeCategory.all,
            title: 'Performance Test',
          ),
        ),
      );
    }

    testWidgets('handles 50 recipes without performance issues', (WidgetTester tester) async {
      // Generate 50 recipes
      final recipes = generateManyRecipes(50);

      // Start a stopwatch to measure performance
      final stopwatch = Stopwatch()..start();

      // Build the widget tree
      await tester.pumpWidget(buildScreen(recipes));
      final buildTime = stopwatch.elapsedMilliseconds;
      stopwatch.reset();

      // Wait for animations to complete
      await tester.pumpAndSettle();
      final settleTime = stopwatch.elapsedMilliseconds;

      // Print performance metrics
      debugPrint('Recipe List Performance (50 recipes):');
      debugPrint('Initial build time: $buildTime ms');
      debugPrint('Animation settle time: $settleTime ms');

      // No specific assertions here since performance will vary by device,
      // but this provides data for monitoring performance over time

      // Basic sanity checks
      expect(find.text('Performance Test Recipe 0'), findsOneWidget);
      expect(find.text('Performance Test Recipe 49'), findsNothing); // Not visible without scrolling
    });

    testWidgets('can scroll through large list of recipes smoothly', (WidgetTester tester) async {
      // Generate a large number of recipes
      final recipes = generateManyRecipes(100);

      // Build the widget tree
      await tester.pumpWidget(buildScreen(recipes));
      await tester.pumpAndSettle();

      // Find the list view - assuming it's the first scrollable
      final listFinder = find.byType(Scrollable).first;

      // Start a stopwatch to measure scroll performance
      final stopwatch = Stopwatch()..start();

      // Scroll down slowly
      await tester.drag(listFinder, const Offset(0, -300)); // Scroll down by 300 pixels
      await tester.pump(); // Schedule frame but don't wait for animations
      final firstDragTime = stopwatch.elapsedMilliseconds;
      stopwatch.reset();

      // Scroll down quickly
      await tester.fling(listFinder, const Offset(0, -1000), 1000); // Fast scroll with velocity 1000
      await tester.pump(); // Schedule frame
      final flingTime = stopwatch.elapsedMilliseconds;
      stopwatch.reset();

      // Wait for animations to complete
      await tester.pumpAndSettle();
      final settleTime = stopwatch.elapsedMilliseconds;

      // Print performance metrics
      debugPrint('Recipe List Scroll Performance:');
      debugPrint('Drag frame time: $firstDragTime ms');
      debugPrint('Fling frame time: $flingTime ms');
      debugPrint('Animation settle time: $settleTime ms');

      // Verify that after scrolling, we can see a different part of the list
      // (exact recipe depends on device size and scroll distance)
      expect(find.text('Performance Test Recipe 0'), findsNothing); // Scrolled out of view
    });

    testWidgets('filtering large recipe list is responsive', (WidgetTester tester) async {
      // Generate recipes
      final recipes = generateManyRecipes(100);

      // Build the widget with all recipes
      await tester.pumpWidget(buildScreen(recipes));
      await tester.pumpAndSettle();

      // Count visible recipes in initial view
      final initialRecipeCount = find.textContaining('Performance Test Recipe').evaluate().length;

      // Start a stopwatch to measure filtering performance
      final stopwatch = Stopwatch()..start();

      // Update to show only breakfast recipes
      await tester.pumpWidget(
        ChangeNotifierProvider<RecipeService>.value(
          value: mockRecipeService,
          child: MaterialApp(
            home: RecipeListScreen(
              category: RecipeCategory.breakfast,
              title: 'Breakfast Recipes',
            ),
          ),
        ),
      );
      final filterRenderTime = stopwatch.elapsedMilliseconds;
      stopwatch.reset();

      await tester.pumpAndSettle();
      final filterSettleTime = stopwatch.elapsedMilliseconds;

      // Count visible recipes after filtering
      final filteredRecipeCount = find.textContaining('Performance Test Recipe').evaluate().length;

      // Print performance metrics
      debugPrint('Recipe Filtering Performance:');
      debugPrint('Filter render time: $filterRenderTime ms');
      debugPrint('Filter settle time: $filterSettleTime ms');
      debugPrint('All recipes initially visible: $initialRecipeCount');
      debugPrint('Breakfast recipes visible after filter: $filteredRecipeCount');

      // Verify filtering worked
      expect(filteredRecipeCount < initialRecipeCount, isTrue);
    });
  });
}