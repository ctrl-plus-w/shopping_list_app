import 'package:flutter/material.dart';

import 'package:shopping_list_app/database/models/product/product.dart';
import 'package:shopping_list_app/database/models/cart/cart.dart';

class CartManager extends ChangeNotifier {
  CartManager() {
    setCart();
  }

  Cart? _cart;
  List<Product> _products = [];
  Set<String> _categories = {};
  bool _isLoading = true;

  Cart? get cart => _cart;
  List<Product> get products => _products;
  Set<String> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> setCart() async {
    _cart = await Cart.getOrCreateCurrent();

    await refreshProducts();
  }

  Future<void> refreshProducts() async {
    _isLoading = true;

    if (_cart != null) {
      final products = await _cart!.getProducts();

      final categories = products
          .where((p) => p.category != null)
          .map((p) => p.category!.name)
          .toSet();

      _products = products;
      _categories = categories;
    }

    _isLoading = false;

    notifyListeners();
  }

  Future<void> deleteProduct(Product product) async {
    if (_cart == null) return;

    product.delete();

    refreshProducts();
  }

  Future<void> switchProductFavorite(Product product) async {
    if (cart == null) return;

    if (!product.favorite) {
      product.addToFavorite();
    } else {
      product.removeFromFavorite();
    }

    refreshProducts();
  }
}
