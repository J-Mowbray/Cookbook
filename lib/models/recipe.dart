// models/recipe.dart
import 'recipe_category.dart';

class Recipe {
  final String id; // Unique identifier
  final String name;
  final String description;
  final String ingredients;
  final String instructions;
  final RecipeCategory category;

  const Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.category,
  });

  // Factory constructor to create a Recipe from a Map (useful for JSON parsing)
  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      ingredients: map['ingredients'] ?? '',
      instructions: map['instructions'] ?? '',
      category: RecipeCategory.values.firstWhere(
            (e) => e.toString().split('.').last == map['category'],
        orElse: () => RecipeCategory.all,
      ),
    );
  }

  // Convert Recipe to Map (useful for storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredients': ingredients,
      'instructions': instructions,
      'category': category.toString().split('.').last,
    };
  }

  // Create a copy of this Recipe with given fields replaced with new values
  Recipe copyWith({
    String? id,
    String? name,
    String? description,
    String? ingredients,
    String? instructions,
    RecipeCategory? category,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      category: category ?? this.category,
    );
  }
}