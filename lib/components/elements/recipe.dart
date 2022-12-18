import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shopping_list_app/database/models/cart/cart.dart';

import 'package:shopping_list_app/database/models/recipe/recipe.dart'
    as recipe_model;
import 'package:shopping_list_app/states/cart_manager.dart';

class CustomBorder extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const offset = 3.0;

    // canvas.drawRect(Rect.largest, Paint()..color = Colors.black);

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(0, 0, 8, size.height),
        topLeft: const Radius.circular(6),
        bottomLeft: const Radius.circular(6),
      ),
      Paint()..color = const Color.fromRGBO(32, 94, 187, 1),
    );

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(offset, 0, 8 - offset, size.height),
        topLeft: const Radius.circular(6),
        bottomLeft: const Radius.circular(6),
      ),
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class Recipe extends StatefulWidget {
  final recipe_model.Recipe recipe;

  const Recipe({
    required this.recipe,
    super.key,
  });

  @override
  State<Recipe> createState() => _RecipeState();
}

class _RecipeState extends State<Recipe> {
  void addRecipeToCart(Function refreshProducts) async {
    final recipeProducts = widget.recipe.products;
    final recipeProductsName = recipeProducts.map((product) => product.name);

    // final database = await DatabaseHelper.database;²

    final cart = await Cart.getOrCreateCurrent();
    final cartProducts = await cart.getProducts();
    final cartProductsName = cartProducts.map((product) => product.name);

    // Among every products on the cart, only keeps the products which are
    // on the recipe.
    final productsAlreadyInCart = cartProducts
        .where((product) => recipeProductsName.contains(product.name));

    // Among all the products in the recipe, keeps only those which are
    // not on the cart.
    final productsToAdd = recipeProducts
        .where((product) => !cartProductsName.contains(product.name));

    // Update the quantity of each product already in the cart
    for (final product in productsAlreadyInCart) {
      final correspondingProductInRecipe =
          recipeProducts.firstWhere((p) => p.name == product.name);

      product.updateQuantity(
          product.quantity + correspondingProductInRecipe.quantity);
    }

    // Add all the others products into the cart
    for (final product in productsToAdd) {
      cart.addProduct(product);
    }

    // TODO : Show that the action has been performed.

    // TODO : Check if refresh works.
    await refreshProducts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<CartManager>(
      builder: (context, cartManager, child) => CustomPaint(
        foregroundPainter: CustomBorder(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: const Color.fromRGBO(187, 195, 208, 1),
            ),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.recipe.name, style: theme.textTheme.headline3),
              const SizedBox(height: 12),
              for (final product in widget.recipe.products.take(3))
                Text(
                    "• ${product.name} (${product.quantity} ${product.unit.name})",
                    style: theme.textTheme.bodyText1),
              if (widget.recipe.products.length > 3) const Text("• ..."),
              Align(
                alignment: Alignment.centerRight,
                child: Transform.translate(
                  offset: const Offset(8, 8),
                  child: IconButton(
                    onPressed: () =>
                        addRecipeToCart(cartManager.refreshProducts),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromRGBO(32, 94, 187, 1),
                      ),
                      child: SvgPicture.asset('assets/add_white.svg'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
