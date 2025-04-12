// screens/recipe_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import 'add_edit_recipe_screen.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recipeService = Provider.of<RecipeService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditRecipeScreen(recipe: recipe),
                ),
              ).then((_) {
                // Refresh the recipe data when returning from edit screen
                final updatedRecipe = recipeService.getRecipeById(recipe.id);
                if (updatedRecipe != null && Navigator.canPop(context)) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeDetailScreen(
                        recipe: updatedRecipe,
                      ),
                    ),
                  );
                }
              });
            },
            tooltip: 'Edit Recipe',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Recipe'),
                  content: const Text(
                    'Are you sure you want to delete this recipe? This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Close the dialog first
                        Navigator.pop(ctx);

                        // Delete the recipe
                        await recipeService.deleteRecipe(recipe.id);

                        // Pop back to the recipe list screen and refresh it
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context, true); // Return true to indicate a deletion happened
                        }
                      },
                      child: Text(
                        'DELETE',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Delete Recipe',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recipe.description,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 24.0),
            Text(
              'Ingredients',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8.0),
            Text(
              recipe.ingredients,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24.0),
            Text(
              'Cooking Instructions',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12.0),
            ...buildInstructionsList(context, recipe.instructions),
          ],
        ),
      ),
    );
  }

  List<Widget> buildInstructionsList(BuildContext context, String instructions) {
    final theme = Theme.of(context);
    final List<String> steps = instructions.trim().split('\n');

    return steps.map((step) {
      // Check if the step starts with a number followed by a period
      final match = RegExp(r'^\s*(\d+)\.\s*(.*)$').firstMatch(step);

      if (match != null) {
        final stepNumber = match.group(1);
        final stepText = match.group(2) ?? '';

        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$stepNumber.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  stepText,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        );
      } else {
        // If the step doesn't follow the number format, just display it as is
        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text(
            step,
            style: theme.textTheme.bodyLarge,
          ),
        );
      }
    }).toList();
  }
}