import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../models/recipe_category.dart';
import '../services/recipe_service.dart';

class AddEditRecipeScreen extends StatefulWidget {
  final Recipe? recipe; // Null for add, non-null for edit

  const AddEditRecipeScreen({Key? key, this.recipe}) : super(key: key);

  @override
  State<AddEditRecipeScreen> createState() => _AddEditRecipeScreenState();
}

class _AddEditRecipeScreenState extends State<AddEditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();

  RecipeCategory _selectedCategory = RecipeCategory.all;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();

    // If recipe is provided, we're in edit mode
    if (widget.recipe != null) {
      _isEditing = true;
      _nameController.text = widget.recipe!.name;
      _descriptionController.text = widget.recipe!.description;
      _ingredientsController.text = widget.recipe!.ingredients;
      _instructionsController.text = widget.recipe!.instructions;
      _selectedCategory = widget.recipe!.category;
    } else {
      // Default category for new recipes
      _selectedCategory = RecipeCategory.dinner;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      final recipeService = Provider.of<RecipeService>(context, listen: false);

      if (_isEditing) {
        // Update existing recipe
        final updatedRecipe = widget.recipe!.copyWith(
          name: _nameController.text,
          description: _descriptionController.text,
          ingredients: _ingredientsController.text,
          instructions: _instructionsController.text,
          category: _selectedCategory,
        );

        await recipeService.updateRecipe(updatedRecipe);
      } else {
        // Add new recipe
        await recipeService.addRecipe(
          name: _nameController.text,
          description: _descriptionController.text,
          ingredients: _ingredientsController.text,
          instructions: _instructionsController.text,
          category: _selectedCategory,
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Recipe' : 'Add Recipe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveRecipe,
            tooltip: 'Save Recipe',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Recipe Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a recipe name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<RecipeCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: RecipeCategory.values
                    .where((c) => c != RecipeCategory.all) // Exclude 'all' from dropdown
                    .map((category) {
                  final categoryName = category.toString().split('.').last;
                  return DropdownMenuItem(
                    value: category,
                    child: Text(categoryName[0].toUpperCase() + categoryName.substring(1)),
                  );
                }).toList(),
                onChanged: (RecipeCategory? value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _ingredientsController,
                decoration: const InputDecoration(
                  labelText: 'Ingredients',
                  border: OutlineInputBorder(),
                  hintText: 'Enter ingredients separated by commas',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter ingredients';
                  }
                  return null;
                },
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(
                  labelText: 'Cooking Instructions',
                  border: OutlineInputBorder(),
                  hintText: 'Enter instructions with each step on a new line',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter cooking instructions';
                  }
                  return null;
                },
                maxLines: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}