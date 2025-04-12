// repositories/recipe_repository.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';
import '../models/recipe_category.dart';

// Abstract class defining the contract for any recipe data source
abstract class RecipeRepository {
  Future<List<Recipe>> getAllRecipes();
  Future<List<Recipe>> getRecipesByCategory(RecipeCategory category);
  Future<Recipe?> getRecipeById(String id);
  Future<void> addRecipe(Recipe recipe);
  Future<void> updateRecipe(Recipe recipe);
  Future<void> deleteRecipe(String id);
}

// Implementation using local storage (SharedPreferences)
class LocalRecipeRepository implements RecipeRepository {
  static const String _storageKey = 'recipes';

  // Singleton pattern implementation
  static LocalRecipeRepository? _instance;

  LocalRecipeRepository._();

  static LocalRecipeRepository get instance {
    _instance ??= LocalRecipeRepository._();
    return _instance!;
  }

  @override
  Future<List<Recipe>> getAllRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final recipesJson = prefs.getStringList(_storageKey) ?? [];

    if (recipesJson.isEmpty) {
      // Return default recipes if no saved recipes
      return _getDefaultRecipes();
    }

    return recipesJson
        .map((json) => Recipe.fromMap(jsonDecode(json)))
        .toList();
  }

  @override
  Future<List<Recipe>> getRecipesByCategory(RecipeCategory category) async {
    final recipes = await getAllRecipes();

    if (category == RecipeCategory.all) {
      return recipes;
    }

    return recipes.where((recipe) => recipe.category == category).toList();
  }

  @override
  Future<Recipe?> getRecipeById(String id) async {
    final recipes = await getAllRecipes();
    try {
      return recipes.firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addRecipe(Recipe recipe) async {
    final recipes = await getAllRecipes();
    recipes.add(recipe);
    await _saveRecipes(recipes);
  }

  @override
  Future<void> updateRecipe(Recipe updatedRecipe) async {
    final recipes = await getAllRecipes();
    final index = recipes.indexWhere((recipe) => recipe.id == updatedRecipe.id);

    if (index != -1) {
      recipes[index] = updatedRecipe;
      await _saveRecipes(recipes);
    }
  }

  @override
  Future<void> deleteRecipe(String id) async {
    final recipes = await getAllRecipes();
    recipes.removeWhere((recipe) => recipe.id == id);
    await _saveRecipes(recipes);
  }

  Future<void> _saveRecipes(List<Recipe> recipes) async {
    final prefs = await SharedPreferences.getInstance();
    final recipesJson = recipes
        .map((recipe) => jsonEncode(recipe.toMap()))
        .toList();

    await prefs.setStringList(_storageKey, recipesJson);
  }

  // Default recipes that were previously in the enum
  List<Recipe> _getDefaultRecipes() {
    return [
      Recipe(
        id: '1',
        name: 'Tuna Pasta Bake',
        description: 'A delicious baked pasta dish with tuna and sweetcorn',
        ingredients: '500g pasta, 2 tins of tuna chunks in brine, 1 tin of Green Giant Sweetcorn, 1 jar of Home Pride Creamy Tomato and Herb Pasta Sauce, 100g grated cheese',
        instructions: """1. Cook 500g pasta until al dente
2. Drain tuna and sweetcorn
3. Mix pasta, tuna, sweetcorn, and sauce in a casserole dish
4. Top with grated cheese
5. Bake at 180°C for 20 minutes until golden and bubbling""",
        category: RecipeCategory.dinner,
      ),
      Recipe(
        id: '2',
        name: 'Tasty Pie',
        description: 'A versatile pie that can be filled with whatever you fancy',
        ingredients: '500g pastry (ready-made or homemade), your choice of filling ingredients, 1 egg for glazing',
        instructions: """1. Preheat oven to 200°C
2. Roll out pastry and line a pie dish
3. Add your favorite filling
4. Cover with pastry lid and seal edges
5. Brush with beaten egg
6. Bake for 30-40 minutes until golden brown""",
        category: RecipeCategory.lunch,
      ),
      Recipe(
        id: '3',
        name: 'Fluffy Pancakes',
        description: 'Light and fluffy pancakes perfect for breakfast',
        ingredients: '200g flour, 2 eggs, 300ml milk, 1 tbsp sugar, pinch of salt, butter for cooking',
        instructions: """1. Mix flour, sugar and salt in a bowl
2. Beat eggs and milk together
3. Gradually whisk the liquid into the dry ingredients
4. Heat a non-stick pan and add a small knob of butter
5. Pour small amounts of batter into the pan
6. Cook until bubbles appear, then flip and cook other side
7. Serve with your favorite toppings""",
        category: RecipeCategory.breakfast,
      ),
      Recipe(
        id: '4',
        name: 'Chocolate Brownies',
        description: 'Rich, fudgy chocolate brownies for a sweet treat',
        ingredients: '200g dark chocolate, 175g butter, 325g sugar, 130g flour, 3 eggs, cocoa powder',
        instructions: """1. Preheat oven to 170°C and line a square baking tin
2. Melt chocolate and butter together
3. Mix in sugar, then add eggs one at a time
4. Fold in flour and cocoa powder
5. Pour into the tin and bake for 25-30 minutes
6. Allow to cool before cutting into squares""",
        category: RecipeCategory.dessert,
      ),
    ];
  }
}