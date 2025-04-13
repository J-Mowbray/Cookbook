// File: test/screens/recipe_list_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cookbook/models/recipe.dart';
import 'package:cookbook/models/recipe_category.dart';
import 'package:cookbook/screens/recipe_list_screen.dart';
import 'package:cookbook/services/recipe_service.dart';
import '../mocks/mock_recipe_service.dart';

void main() {
  group('RecipeListScreen Tests', () {
    late MockRecipeService mockRecipeService;

    final testRecipes = [
      Recipe(
        id: '1',
        name: 'Breakfast Recipe',
        description: 'A breakfast description',
        ingredients: 'Breakfast ingredients',
        instructions: 'Breakfast instructions',
        category: RecipeCategory.breakfast,
      ),
      Recipe(
        id: '2',
        name: 'Lunch Recipe',
        description: 'A lunch description',
        ingredients: 'Lunch ingredients',
        instructions: 'Lunch instructions',
        category: RecipeCategory.lunch,
      ),
    ];

    setUp(() {
      mockRecipeService = MockRecipeService();
      // Pre-load the service with test recipes
      mockRecipeService.setRecipes(testRecipes);
    });

    Widget buildScreen({RecipeCategory category = RecipeCategory.all}) {
      return ChangeNotifierProvider<RecipeService>.value(
        value: mockRecipeService,
        child: MaterialApp(
          home: RecipeListScreen(
            category: category,
            title: 'Test Screen',
          ),
        ),
      );
    }

    testWidgets('displays recipes correctly', (WidgetTester tester) async {
      // Build the screen with all categories
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Check that both recipes are displayed
      expect(find.text('Breakfast Recipe'), findsOneWidget);
      expect(find.text('Lunch Recipe'), findsOneWidget);
      expect(find.text('A breakfast description'), findsOneWidget);
      expect(find.text('A lunch description'), findsOneWidget);
    });

    testWidgets('filters recipes by category', (WidgetTester tester) async {
      // Build the screen with only breakfast category
      await tester.pumpWidget(buildScreen(category: RecipeCategory.breakfast));
      await tester.pumpAndSettle();

      // Check that only breakfast recipe is shown
      expect(find.text('Breakfast Recipe'), findsOneWidget);
      expect(find.text('A breakfast description'), findsOneWidget);

      // Lunch recipe should not be visible
      expect(find.text('Lunch Recipe'), findsNothing);
      expect(find.text('A lunch description'), findsNothing);
    });

    testWidgets('shows empty state when no recipes', (WidgetTester tester) async {
      // Set up empty recipe list
      mockRecipeService.setRecipes([]);

      // Build the screen
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Check for empty state message
      expect(find.text('No recipes in this category yet!'), findsOneWidget);
    });

    testWidgets('shows loading indicator', (WidgetTester tester) async {
      // Set loading state to true
      mockRecipeService.setLoading(true);

      // Build the screen
      await tester.pumpWidget(buildScreen());
      await tester.pump();  // Don't use pumpAndSettle as it waits for animations

      // Check for loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Recipe items should not be visible while loading
      expect(find.text('Breakfast Recipe'), findsNothing);
      expect(find.text('Lunch Recipe'), findsNothing);
    });

    testWidgets('displays FloatingActionButton for adding recipes', (WidgetTester tester) async {
      // Build the screen
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Check for FAB
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}