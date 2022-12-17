import 'package:flutter/material.dart';
import 'package:shopping_list_app/database/models/product/product.dart';

class FavoriteManager extends ChangeNotifier {
  FavoriteManager() {
    refreshProducts();
  }

  List<Product> _products = [];
  Set<String> _categories = {};
  bool _isLoading = true;

  bool get isLoading => _isLoading;
  List<Product> get products => _products;
  Set<String> get categories => _categories;

  Future<void> refreshProducts() async {
    _isLoading = true;

    _products = await Product.getAll(favorite: true);

    _categories = _products
        .where((p) => p.category != null)
        .map((p) => p.category!.name)
        .toSet();

    _isLoading = false;

    notifyListeners();
  }

  Future<void> switchProductFavorite(Product product) async {
    if (!product.favorite) {
      product.addToFavorite();
    } else {
      product.removeFromFavorite();
    }

    refreshProducts();
  }
}
