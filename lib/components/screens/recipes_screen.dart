import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Elements
import 'package:shopping_list_app/components/elements/recipe.dart';

// States
import 'package:shopping_list_app/states/recipes_manager.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({Key? key}) : super(key: key);

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<RecipesManager>(
      builder: (context, recipesManager, child) {
        if (recipesManager.isLoading) {
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
                itemCount: recipesManager.recipes.length,
                shrinkWrap: true,
                itemBuilder: (context, index) =>
                    Recipe(recipe: recipesManager.recipes[index]),
              )
            ],
          ),
        );
      },
    );
  }
}
