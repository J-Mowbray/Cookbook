import 'package:flutter_test/flutter_test.dart';
import 'package:cookbook/models/recipe_category.dart';

void main() {
  group('RecipeCategory Tests', () {
    test('has correct values in correct order', () {
      // Verify all categories and their order
      expect(RecipeCategory.values.length, 5);
      expect(RecipeCategory.values[0], RecipeCategory.all);
      expect(RecipeCategory.values[1], RecipeCategory.breakfast);
      expect(RecipeCategory.values[2], RecipeCategory.lunch);
      expect(RecipeCategory.values[3], RecipeCategory.dinner);
      expect(RecipeCategory.values[4], RecipeCategory.dessert);
    });

    test('toString returns correct format', () {
      // Check string representation for use in UI and storage
      expect(RecipeCategory.all.toString(), 'RecipeCategory.all');
      expect(RecipeCategory.breakfast.toString(), 'RecipeCategory.breakfast');
      expect(RecipeCategory.lunch.toString(), 'RecipeCategory.lunch');
      expect(RecipeCategory.dinner.toString(), 'RecipeCategory.dinner');
      expect(RecipeCategory.dessert.toString(), 'RecipeCategory.dessert');
    });

    test('can retrieve category name from toString result', () {
      // Ensure we can parse the string representation back to get just the category name
      final categoryString = RecipeCategory.dinner.toString();
      final categoryName = categoryString.split('.').last;
      expect(categoryName, 'dinner');
    });
  });
}