import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_list_app/components/elements/product.dart';
import 'package:shopping_list_app/components/modules/product_category.dart';

// States
import 'package:shopping_list_app/states/favorite_manager.dart';

class FavoriteProductsScreen extends StatelessWidget {
  const FavoriteProductsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<FavoriteManager>(
      builder: (context, favoriteManager, child) {
        if (favoriteManager.isLoading) {
          return Scaffold(
            body: Container(
              padding: const EdgeInsets.all(16),
              child: const Text("Loading..."),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.only(top: 48, left: 32, right: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Produits Favoris",
                style: theme.textTheme.headline1,
              ),
              const SizedBox(height: 8),
              Text(
                "Voici la liste des produits que vous avez ajoutés en favoris.",
                style: theme.textTheme.subtitle1,
              ),
              ListView.builder(
                itemCount: favoriteManager.categories.length,
                shrinkWrap: true,
                itemBuilder: ((context, index) => Column(
                      children: [
                        ProductCategory(
                          name: favoriteManager.categories.elementAt(index),
                          products: favoriteManager.products
                              .where(
                                (p) =>
                                    p.category.name ==
                                    favoriteManager.categories.elementAt(index),
                              )
                              .map(
                                (p) => Product(
                                  product: p,
                                  deleteDismissAction: (p) => {},
                                  favoriteDismissAction:
                                      favoriteManager.switchProductFavorite,
                                  deletable: false,
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 36),
                      ],
                    )),
              ),
            ],
          ),
        );
      },
    );
  }
}
