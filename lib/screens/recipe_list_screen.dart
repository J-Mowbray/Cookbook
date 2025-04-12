// screens/recipe_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe_category.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import 'recipe_detail_screen.dart';
import 'add_edit_recipe_screen.dart';

class RecipeListScreen extends StatefulWidget {
  final RecipeCategory category;
  final String title;

  const RecipeListScreen({
    Key? key,
    required this.category,
    required this.title,
  }) : super(key: key);

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Consumer<RecipeService>(
        builder: (context, recipeService, child) {
          // If still loading
          if (recipeService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filter recipes by category
          final recipes = widget.category == RecipeCategory.all
              ? recipeService.recipes
              : recipeService.recipes.where((r) => r.category == widget.category).toList();

          if (recipes.isEmpty) {
            return Center(
              child: Text(
                'No recipes in this category yet!',
                style: theme.textTheme.bodyLarge,
              ),
            );
          }

          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    recipe.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    recipe.description,
                    style: theme.textTheme.bodyMedium,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: theme.colorScheme.primary,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditRecipeScreen(
                                recipe: recipe,
                              ),
                            ),
                          ).then((_) {
                            // Force UI refresh after edit
                            setState(() {});
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: theme.colorScheme.error,
                        ),
                        onPressed: () {
                          _showDeleteDialog(context, recipe);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.arrow_forward_ios,
                          color: theme.colorScheme.primary,
                          size: 18,
                        ),
                        onPressed: () {
                          _navigateToDetail(context, recipe);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    _navigateToDetail(context, recipe);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditRecipeScreen(),
            ),
          ).then((_) {
            // Force UI refresh after adding a new recipe
            setState(() {});
          });
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Recipe',
      ),
    );
  }

  // Extract method to show delete dialog
  void _showDeleteDialog(BuildContext context, Recipe recipe) {
    final recipeService = Provider.of<RecipeService>(context, listen: false);
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: Text(
          'Are you sure you want to delete "${recipe.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog
              await recipeService.deleteRecipe(recipe.id);

              // Force UI refresh after deletion
              if (mounted) {
                setState(() {});

                // Show confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${recipe.name} deleted')),
                );
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
  }

  // Extract method to navigate to detail screen
  void _navigateToDetail(BuildContext context, Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailScreen(
          recipe: recipe,
        ),
      ),
    ).then((deleted) {
      // If recipe was deleted in detail screen, refresh this screen
      if (deleted == true) {
        setState(() {});
      }
    });
  }
}