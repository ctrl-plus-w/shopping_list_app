import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Models
import 'package:shopping_list_app/database/models/product/product.dart';
import 'package:shopping_list_app/database/models/recipe/recipe.dart';

// Modules
import 'package:shopping_list_app/components/modules/popup_container.dart';

// Elements
import 'package:shopping_list_app/components/elements/custom_checkbox.dart';
import 'package:shopping_list_app/states/recipe_manager.dart';

const String pagePrefPrefix = "new_recipe_page";
getPrefPropName(String propName) => pagePrefPrefix + propName;

class NewRecipePopup extends StatefulWidget {
  const NewRecipePopup({super.key});

  @override
  State<NewRecipePopup> createState() => _NewRecipePopupState();
}

class _NewRecipePopupState extends State<NewRecipePopup> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameInputController;

  late List<Product> _favoriteProducts = [];

  late Map<int, bool> _checkboxesValue = {};

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();

      final favProducts = await Product.getAll(favorite: true);

      setState(() {
        _nameInputController = TextEditingController(
          text: prefs.getString(getPrefPropName('name')),
        );

        _favoriteProducts = favProducts;
        _checkboxesValue = {for (var el in favProducts) el.id: false};

        _isLoading = false;
      });
    });
  }

  Future<void> submit(Function refreshRecipes) async {
    final name = _nameInputController.text;

    Recipe recipe = Recipe(
      name: name,
    );

    recipe.id = await recipe.create();

    await recipe.addProducts(_favoriteProducts);

    await refreshRecipes();

    // Because the func is async, we need to check if the component is mounted before calling the Navigator.
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle formInputTextStyle = TextStyle(fontSize: 14);

    final theme = Theme.of(context);

    if (_isLoading) {
      // TODO : When loading, show the skeleton instead of the shrinked box.
      return const SizedBox.shrink();
    }

    return Consumer<RecipeManager>(
      builder: (context, recipeManager, child) => PopupContainer(
        child: Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Créer une recette", style: theme.textTheme.headline2),
              const SizedBox(height: 6),
              Text("Des produits pourront être ajoutés ultérieurement",
                  style: theme.textTheme.subtitle1),
              const SizedBox(height: 29),
              Form(
                key: _formKey,
                child: Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name Input Field
                      Text("Nom de la recette",
                          style: theme.textTheme.bodyText1),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4,
                              color: Colors.black.withOpacity(0.11),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          controller: _nameInputController,
                          style: theme.textTheme.bodyText1!
                              .merge(formInputTextStyle),
                          decoration: const InputDecoration(
                                  hintText: "Boeuf bourgignon")
                              .applyDefaults(theme.inputDecorationTheme),
                          validator: (value) {
                            // Check if the string isn't empty.
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le nom d\'une recette';
                            }

                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Ajouter des produits",
                        style: theme.textTheme.bodyText1,
                      ),
                      const SizedBox(height: 8),
                      ListView.separated(
                        itemCount: _favoriteProducts.length,
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          final key = _checkboxesValue.keys.elementAt(index);

                          return Row(
                            children: [
                              CustomCheckbox(
                                title: _favoriteProducts
                                    .firstWhere((product) => product.id == key)
                                    .name,
                                value: _checkboxesValue[key] ?? false,
                                onChange: (value) => setState(() {
                                  _checkboxesValue[key] = value;
                                }),
                              ),
                            ],
                          );
                        },
                      ),

                      const Spacer(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: Navigator.of(context).pop,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset('assets/arrow_left.svg'),
                                const SizedBox(width: 8),
                                const Text('Recettes'),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                submit(recipeManager.refreshRecipes);
                              }
                            },
                            child: const Text('Créer la recette'),
                          ),
                        ],
                      ),
                    ],
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
