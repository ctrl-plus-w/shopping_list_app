import 'package:flutter/material.dart';

// Models
import 'package:shopping_list_app/database/models/product/product.dart';
import 'package:shopping_list_app/database/models/recipe/recipe.dart';

class RecipeManager extends ChangeNotifier {
  Recipe? _recipe;
  List<Product> _products = [];
  Set<String> _categories = {};

  Recipe? get recipe => _recipe;
  List<Product> get products => _products;
  Set<String> get categories => _categories;

  Future<void> setRecipe(Recipe recipe) async {
    _recipe = recipe;

    updateRecipe();
  }

  void updateRecipe() {
    final recipe = _recipe;
    if (recipe == null) return;

    _products = recipe.products;
    _categories = recipe.products.map((p) => p.category.name).toSet();

    notifyListeners();
  }

  Future<void> deleteFromRecipe(Product product) async {
    final recipe = _recipe;
    if (recipe == null) return;

    await recipe.removeProduct(product);

    recipe.products = recipe.products.where((p) => p.id != product.id).toList();

    updateRecipe();
  }

  Future<void> switchProductFavorite(Product product) async {
    final recipe = _recipe;
    if (recipe == null) return;

    if (!product.favorite) {
      product.addToFavorite();
    } else {
      product.removeFromFavorite();
    }

    notifyListeners();
  }
}
