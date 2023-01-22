import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

// Modules
import 'package:shopping_list_app/components/modules/product_category.dart';

// Elements
import 'package:shopping_list_app/components/elements/product.dart';

// States
import 'package:shopping_list_app/states/recipe_manager.dart';
import 'package:shopping_list_app/states/screen_manager.dart';

class RecipeScreen extends StatelessWidget {
  const RecipeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer2<RecipeManager, ScreenManager>(
        builder: (context, recipeManager, screenManager, child) {
      return SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 48, left: 32, right: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () {
                  screenManager.setScreen(ScreensName.recipesScreen);
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/arrow_left.svg'),
                    const SizedBox(width: 8),
                    const Text('Listes Archivées'),
                  ],
                ),
              ),
              Text(
                recipeManager.recipe!.name,
                style: theme.textTheme.headline1,
              ),
              const SizedBox(height: 27),
              ListView.builder(
                itemCount: recipeManager.categories.length,
                shrinkWrap: true,
                itemBuilder: ((context, index) => Column(
                      children: [
                        ProductCategory(
                          name: recipeManager.categories.elementAt(index),
                          products: recipeManager.products
                              .where(
                                (p) =>
                                    p.category.name ==
                                    recipeManager.categories.elementAt(index),
                              )
                              .map(
                                (p) => Product(
                                  product: p,
                                  deleteDismissAction:
                                      recipeManager.deleteFromRecipe,
                                  favoriteDismissAction:
                                      recipeManager.switchProductFavorite,
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
        ),
      );
    });
  }
}
