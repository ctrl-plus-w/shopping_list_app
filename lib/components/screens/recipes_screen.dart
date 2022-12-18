import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_list_app/components/elements/recipe.dart';

// States
import 'package:shopping_list_app/states/recipe_manager.dart';

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<RecipeManager>(
      builder: (context, recipeManager, child) {
        if (recipeManager.isLoading) {
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
                "Recettes",
                style: theme.textTheme.headline1,
              ),
              const SizedBox(height: 8),
              Text(
                "Voici la liste des recettes sauvegardées",
                style: theme.textTheme.subtitle1,
              ),
              ListView.builder(
                  itemCount: recipeManager.recipes.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) =>
                      Recipe(recipe: recipeManager.recipes[index]))
            ],
          ),
        );
      },
    );
  }
}
