// File: test/screens/recipe_detail_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cookbook/models/recipe.dart';
import 'package:cookbook/models/recipe_category.dart';
import 'package:cookbook/screens/recipe_detail_screen.dart';
import 'package:cookbook/services/recipe_service.dart';
import '../mocks/mock_recipe_service.dart';

void main() {
  group('RecipeDetailScreen Tests', () {
    late MockRecipeService mockRecipeService;

    final testRecipe = Recipe(
      id: '1',
      name: 'Test Recipe',
      description: 'Test Description',
      ingredients: 'Ingredient 1, Ingredient 2, Ingredient 3',
      instructions: '1. Step one\n2. Step two\n3. Step three',
      category: RecipeCategory.dinner,
    );

    setUp(() {
      mockRecipeService = MockRecipeService();
    });

    Widget buildScreen(Recipe recipe) {
      return ChangeNotifierProvider<RecipeService>.value(
        value: mockRecipeService,
        child: MaterialApp(
          home: RecipeDetailScreen(recipe: recipe),
        ),
      );
    }

    testWidgets('displays recipe details correctly', (WidgetTester tester) async {
      // Build the screen
      await tester.pumpWidget(buildScreen(testRecipe));
      await tester.pumpAndSettle();

      // Check that recipe details are displayed
      expect(find.text('Test Recipe'), findsOneWidget); // Title in AppBar
      expect(find.text('Test Description'), findsOneWidget);

      // Check section headings
      expect(find.text('Ingredients'), findsOneWidget);
      expect(find.text('Cooking Instructions'), findsOneWidget);

      // Check ingredients are displayed
      expect(find.text('Ingredient 1, Ingredient 2, Ingredient 3'), findsOneWidget);

      // Check instructional steps
      // These might be displayed in a custom way, so we check the text content
      expect(find.text('1.'), findsOneWidget);
      expect(find.text('Step one'), findsOneWidget);
      expect(find.text('2.'), findsOneWidget);
      expect(find.text('Step two'), findsOneWidget);
      expect(find.text('3.'), findsOneWidget);
      expect(find.text('Step three'), findsOneWidget);
    });

    testWidgets('has edit and delete buttons', (WidgetTester tester) async {
      // Build the screen
      await tester.pumpWidget(buildScreen(testRecipe));
      await tester.pumpAndSettle();

      // Check for edit and delete buttons in AppBar
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('delete button shows confirmation dialog', (WidgetTester tester) async {
      // Build the screen
      await tester.pumpWidget(buildScreen(testRecipe));
      await tester.pumpAndSettle();

      // Tap the delete button
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Check that confirmation dialog appears
      expect(find.text('Delete Recipe'), findsOneWidget);
      expect(find.text('Are you sure you want to delete this recipe? This action cannot be undone.'),
          findsOneWidget);
      expect(find.text('CANCEL'), findsOneWidget);
      expect(find.text('DELETE'), findsOneWidget);
    });

    testWidgets('handles recipes with long content', (WidgetTester tester) async {
      // Create a recipe with very long content
      final longRecipe = Recipe(
        id: '2',
        name: 'Recipe With Very Long Name That Would Normally Cause Layout Issues',
        description: 'This is a very long description that spans multiple lines to test how well the screen handles long text content without overflowing or causing layout problems.',
        ingredients: 'Ingredient 1, Ingredient 2, Ingredient 3, Ingredient 4, Ingredient 5, Ingredient 6, Ingredient 7, Ingredient 8, Ingredient 9, Ingredient 10',
        instructions: '1. This is a very long step with detailed instructions that would normally wrap to multiple lines.\n2. Another long step with even more details and instructions that would test the layout capabilities.\n3. Step three\n4. Step four\n5. Step five',
        category: RecipeCategory.dinner,
      );

      // Build the screen
      await tester.pumpWidget(buildScreen(longRecipe));
      await tester.pumpAndSettle();

      // If no exceptions are thrown, consider the test passed
      // We can also check that some of the long content is visible
      expect(find.text('Recipe With Very Long Name That Would Normally Cause Layout Issues'), findsOneWidget);
      expect(find.text('This is a very long description that spans multiple lines to test how well the screen handles long text content without overflowing or causing layout problems.'), findsOneWidget);
    });
  });
}