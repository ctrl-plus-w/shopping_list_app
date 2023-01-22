import 'package:flutter/material.dart';
import 'package:shopping_list_app/database/models/recipe/recipe.dart';

class RecipesManager extends ChangeNotifier {
  RecipesManager() {
    refreshRecipes();
  }

  List<Recipe> _recipes = [];
  bool _isLoading = true;

  bool get isLoading => _isLoading;
  List<Recipe> get recipes => _recipes;

  Future<void> refreshRecipes() async {
    _isLoading = true;

    _recipes = await Recipe.getAll();

    _isLoading = false;

    notifyListeners();
  }
}
