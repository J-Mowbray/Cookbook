// File: integration_test/app_test.dart
import 'package:cookbook/models/recipe_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cookbook/main.dart' as app;
import 'package:cookbook/screens/recipe_list_screen.dart'; // Import for finding ListTile

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Complete Recipe App Flow Tests', () {
    testWidgets('Full recipe lifecycle - create, view, edit, delete', (
        WidgetTester tester,
        ) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify we're on the home screen (All Recipes tab)
      expect(find.text('All Recipes'), findsOneWidget);

      // Navigate to add recipe screen
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text('Add Recipe'), findsOneWidget);

      // Fill in recipe details
      await tester.enterText(find.widgetWithText(TextFormField, 'Recipe Name'), 'Integration Test Recipe');
      await tester.enterText(find.widgetWithText(TextFormField, 'Description'), 'Recipe created during integration testing');
      await tester.enterText(find.widgetWithText(TextFormField, 'Ingredients'), 'Test ingredient 1, Test ingredient 2, Test ingredient 3');
      await tester.enterText(find.widgetWithText(TextFormField, 'Cooking Instructions'), '1. Step one\n2. Step two\n3. Step three');

      // Select dinner category
      await tester.tap(find.byType(DropdownButtonFormField<RecipeCategory>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dinner').last);
      await tester.pumpAndSettle();

      // Save the recipe
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      // Verify recipe is listed
      expect(find.text('Integration Test Recipe'), findsOneWidget);

      // View recipe details
      await tester.tap(find.text('Integration Test Recipe'));
      await tester.pumpAndSettle();
      expect(find.text('Integration Test Recipe'), findsOneWidget);
      expect(find.text('Recipe created during integration testing'), findsOneWidget);
      expect(find.text('Test ingredient 1, Test ingredient 2, Test ingredient 3'), findsOneWidget);
      expect(find.text('Step one'), findsOneWidget);

      // Navigate to edit screen
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();
      expect(find.text('Edit Recipe'), findsOneWidget);

      // Update recipe name
      await tester.enterText(find.widgetWithText(TextFormField, 'Integration Test Recipe'), 'Updated Integration Test Recipe');
      await tester.pumpAndSettle();

      // Save changes
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      // Verify updated name is displayed
      expect(find.text('Updated Integration Test Recipe'), findsOneWidget);

      // Delete the recipe
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      expect(find.text('Delete Recipe'), findsOneWidget);
      await tester.tap(find.text('DELETE'));
      await tester.pumpAndSettle();

      // Verify recipe is no longer listed
      expect(find.text('Updated Integration Test Recipe'), findsNothing);
    });

    testWidgets('Category filtering works correctly', (
        WidgetTester tester,
        ) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Helper function to add a recipe
      Future<void> addRecipe(String name, RecipeCategory category) async {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        await tester.enterText(find.widgetWithText(TextFormField, 'Recipe Name'), name);
        await tester.enterText(find.widgetWithText(TextFormField, 'Description'), 'Description for $name');
        await tester.enterText(find.widgetWithText(TextFormField, 'Ingredients'), 'Ingredients for $name');
        await tester.enterText(find.widgetWithText(TextFormField, 'Cooking Instructions'), 'Instructions for $name');
        await tester.tap(find.byType(DropdownButtonFormField<RecipeCategory>));
        await tester.pumpAndSettle();
        final categoryName = category.toString().split('.').last;
        final displayName = categoryName[0].toUpperCase() + categoryName.substring(1);
        await tester.tap(find.text(displayName).last);
        await tester.pumpAndSettle();
        print('Adding recipe "$name" with category: $category'); // DEBUG PRINT
        await tester.tap(find.byIcon(Icons.save));
        await tester.pumpAndSettle();
      }

      // Add test recipes
      await addRecipe('Breakfast Recipe', RecipeCategory.breakfast);
      await addRecipe('Lunch Recipe', RecipeCategory.lunch);
      await addRecipe('Dinner Recipe', RecipeCategory.dinner);
      await addRecipe('Dessert Recipe', RecipeCategory.dessert);

      // Verify all recipes are visible initially
      expect(find.text('Breakfast Recipe'), findsOneWidget);
      expect(find.text('Lunch Recipe'), findsOneWidget);
      expect(find.text('Dinner Recipe'), findsOneWidget);
      expect(find.text('Dessert Recipe'), findsOneWidget);

      // Test filtering
      await tester.tap(find.text('Breakfast'));
      await tester.pumpAndSettle();
      expect(find.text('Breakfast Recipe'), findsOneWidget);
      expect(find.text('Lunch Recipe'), findsNothing);
      expect(find.text('Dinner Recipe'), findsNothing);
      expect(find.text('Dessert Recipe'), findsNothing);

      await tester.tap(find.text('Lunch'));
      await tester.pumpAndSettle();
      expect(find.text('Breakfast Recipe'), findsNothing);
      expect(find.text('Lunch Recipe'), findsOneWidget);
      expect(find.text('Dinner Recipe'), findsNothing);
      expect(find.text('Dessert Recipe'), findsNothing);

      await tester.tap(find.text('Dinner'));
      await tester.pumpAndSettle();
      expect(find.text('Breakfast Recipe'), findsNothing);
      expect(find.text('Lunch Recipe'), findsNothing);
      expect(find.text('Dinner Recipe'), findsOneWidget);
      expect(find.text('Dessert Recipe'), findsNothing);

      await tester.tap(find.text('Dessert'));
      await tester.pumpAndSettle();
      final dessertRecipes = tester.widgetList<ListTile>(find.byType(ListTile));
      print('ListTile titles after tapping Dessert: ${dessertRecipes.map((tile) => tile.title is Text ? (tile.title as Text).data : null).toList()}'); // DEBUG PRINT
      expect(find.text('Dessert Recipe'), findsOneWidget);

      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
      expect(find.text('Breakfast Recipe'), findsOneWidget);
      expect(find.text('Lunch Recipe'), findsOneWidget);
      expect(find.text('Dinner Recipe'), findsOneWidget);
      expect(find.text('Dessert Recipe'), findsOneWidget);
    });

    testWidgets('Theme toggle works correctly', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      debugPrint('AppBar Widgets at start: ${tester.widgetList(find.byType(AppBar))}'); // DEBUG PRINT

      final themeToggleButton =
          find.byKey(const Key('theme_toggle_button')).first; // Ensure the key is used in your IconButton

      await tester.tap(themeToggleButton);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.nightlight_round), findsOneWidget);

      await tester.tap(find.byIcon(Icons.nightlight_round));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.wb_sunny_outlined), findsOneWidget);
    });
  });
}