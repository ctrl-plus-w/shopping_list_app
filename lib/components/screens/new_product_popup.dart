import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Modules
import 'package:shopping_list_app/components/modules/popup_container.dart';
import 'package:shopping_list_app/components/modules/search_input.dart';

// Database
import 'package:shopping_list_app/database/database.dart';
import 'package:shopping_list_app/database/models/cart/cart.dart';
import 'package:shopping_list_app/database/models/category/category.dart';
import 'package:shopping_list_app/database/models/product/product.dart';

// Models
import 'package:shopping_list_app/database/models/unit/unit.dart';
import 'package:shopping_list_app/helpers/preferences.dart';
import 'package:slugify/slugify.dart';

const String pagePrefPrefix = "new_produt_page";
const String generalPrefPrefix = "general";
const String categoryPrefPrefix = "category";
const String favoritePrefPrefix = "favorite";

enum States {
  general,
  category,
  favorite,
}

class NewProductPopup extends StatefulWidget {
  const NewProductPopup({Key? key}) : super(key: key);

  @override
  State<NewProductPopup> createState() => _NewProductPopupState();
}

class NavigationAutomata {
  final States state;

  const NavigationAutomata(this.state);

  NavigationAutomata? next() {
    if (state == States.general) {
      return const NavigationAutomata(States.category);
    }

    if (state == States.category) {
      return const NavigationAutomata(States.favorite);
    }

    return null;
  }

  NavigationAutomata? previous() {
    if (state == States.favorite) {
      return const NavigationAutomata(States.category);
    }

    if (state == States.category) {
      return const NavigationAutomata(States.general);
    }

    return null;
  }
}

class _NewProductPopupState extends State<NewProductPopup> {
  NavigationAutomata _state = const NavigationAutomata(States.general);

  List<Unit> _units = <Unit>[];
  List<Category> _categories = <Category>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    DatabaseHelper.database.whenComplete(() async {
      List<Unit> units = await Unit.getAll();
      List<Category> categories = await Category.getAll();

      setState(() {
        _units = units;
        _categories = categories;
        _isLoading = false;
      });
    });
  }

  void setNextState() {
    NavigationAutomata? nextState = _state.next();

    if (nextState != null) {
      setState(() {
        _state = nextState;
      });
    }
  }

  void setPreviousState() {
    NavigationAutomata? previousState = _state.previous();

    if (previousState != null) {
      setState(() {
        _state = previousState;
      });
    }
  }

  void goToState(States state) {
    setState(() => _state = NavigationAutomata(state));
  }

  void submit() async {
    final prefs = await SharedPreferences.getInstance();

    // Handling all the saved fields of the GENERAL SECTION
    Function getPropName =
        prefPropNameGetter(pagePrefPrefix, generalPrefPrefix);

    final String? productName = prefs.getString(getPropName("name"));
    final String? quantityType = prefs.getString(getPropName("quantity_type"));
    final int? quantity = prefs.getInt(getPropName("quantity"));

    if (productName == null || quantityType == null || quantity == null) {
      goToState(States.category);

      return;
    }

    // Handling all the saved fields of the CATEGORY SECTION
    getPropName = prefPropNameGetter(pagePrefPrefix, categoryPrefPrefix);

    final String? categoryName = prefs.getString(getPropName("name"));
    if (categoryName == null) {
      return goToState(States.category);
    }

    final category = await Category.getByName(categoryName);
    if (category == null) {
      return goToState(States.category);
    }

    // Handling all the saved fields of the FAVORITE SECTION
    getPropName = prefPropNameGetter(pagePrefPrefix, favoritePrefPrefix);

    final bool isFavorite = prefs.getBool(getPropName("enabled")) ?? false;

    // Handling all the data and creating the product
    final unit = await Unit.getByName(quantityType);
    if (unit == null) {
      goToState(States.category);

      return;
    }

    final product = Product(
      name: productName,
      quantity: quantity,
      unit: unit,
      favorite: isFavorite,
      category: category,
    );

    final cart = await Cart.getOrCreateCurrent();
    await cart.addProduct(product);

    // Clear the shared prefs
    prefs.clear();

    // Because the func is async, we need to check if the component is mounted before calling the Navigator.
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const PopupContainer(
        child: Text("Loading..."),
      );
    }

    final theme = Theme.of(context);

    return PopupContainer(
      child: Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nouveau produit", style: theme.textTheme.headline2),
            const SizedBox(height: 6),
            Text("Ajouter un nouveau produit.",
                style: theme.textTheme.subtitle1),
            const SizedBox(height: 29),
            if (_state.state == States.general)
              GeneralStepFormCategory(
                units: _units,
                setNextState: setNextState,
                setPreviousState: setPreviousState,
              )
            else if (_state.state == States.category)
              CategoryStepFormCategory(
                categories: _categories,
                setNextState: setNextState,
                setPreviousState: setPreviousState,
              )
            else if (_state.state == States.favorite)
              FavoriteStepFormCategory(
                setNextState: setNextState,
                setPreviousState: setPreviousState,
                submit: submit,
              ),
          ],
        ),
      ),
    );
  }
}

class FavoriteStepFormCategory extends StatelessWidget {
  final getPropName = prefPropNameGetter(pagePrefPrefix, favoritePrefPrefix);

  final void Function() setNextState;
  final void Function() setPreviousState;
  final void Function() submit;

  FavoriteStepFormCategory({
    Key? key,
    required this.setNextState,
    required this.setPreviousState,
    required this.submit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Voulez vous ajouter le produit aux favoris ?",
                  style: theme.textTheme.subtitle1,
                  textAlign: TextAlign.center,
                ),
                // TODO : Make a box around the icon so as to center it (create a centered frame around it on figma)
                SvgPicture.asset('assets/favorite_illustration.svg'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        submit();
                      },
                      child: const Text('Non merci.'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();

                        await prefs.setBool(getPropName('enabled'), true);
                        submit();
                      },
                      child: const Text('Oui l\'ajouter !'),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class CategoryStepFormCategory extends StatefulWidget {
  final void Function() setNextState;
  final void Function() setPreviousState;
  final List<Category> categories;

  const CategoryStepFormCategory({
    Key? key,
    required this.categories,
    required this.setNextState,
    required this.setPreviousState,
  }) : super(key: key);

  @override
  State<CategoryStepFormCategory> createState() =>
      _CategoryStepFormCategoryState();
}

class _CategoryStepFormCategoryState extends State<CategoryStepFormCategory> {
  final getPrefPropName =
      prefPropNameGetter(pagePrefPrefix, categoryPrefPrefix);

  final _formKey = GlobalKey<FormState>();

  final _categoryInputController = TextEditingController();
  final _categorySelectedController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchInput<Category>(
              label: 'Nom de la catégorie',
              formKey: _formKey,
              data: widget.categories,
              controller: _categoryInputController,
              valueController: _categorySelectedController,
              //
              emptyErrorMessage: 'Error1',
              duplicationErrorMessage: 'Error2',
              //
              getSlug: (dynamic category) => category.slug,
              getLabel: (dynamic category) => category.name,
              getId: (dynamic category) => category.id ?? 1,
              //
              addElement: (String label) async {
                Category category = Category(name: label, slug: slugify(label));
                category.id = await category.insert();
                return category;
              },
            ),

            // Space
            const Spacer(),

            // Next Step Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    widget.setPreviousState();
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/arrow_left.svg'),
                      const SizedBox(width: 8),
                      const Text('Général'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_categorySelectedController.text.isNotEmpty) {
                      final prefs = await SharedPreferences.getInstance();

                      await prefs.setString(
                        getPrefPropName('name'),
                        _categorySelectedController.text,
                      );

                      widget.setNextState();
                    }
                  },
                  child: const Text('Créer le produit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GeneralStepFormCategory extends StatefulWidget {
  final void Function() setNextState;
  final void Function() setPreviousState;
  final List<Unit> units;

  const GeneralStepFormCategory({
    Key? key,
    required this.units,
    required this.setNextState,
    required this.setPreviousState,
  }) : super(key: key);

  @override
  State<GeneralStepFormCategory> createState() =>
      _GeneralStepFormCategoryState();
}

class _GeneralStepFormCategoryState extends State<GeneralStepFormCategory> {
  final getPrefPropName = prefPropNameGetter(pagePrefPrefix, generalPrefPrefix);

  late String defaultUnit;

  final _formKey = GlobalKey<FormState>();

  // Input
  late TextEditingController nameInputController;
  late TextEditingController quantityInputController;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    defaultUnit = widget.units[0].name;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        nameInputController = TextEditingController(
          text: prefs.getString(getPrefPropName('name')),
        );

        quantityInputController = TextEditingController(
          text: (prefs.getInt(getPrefPropName('quantity')) ?? 1).toString(),
        );

        final quantityType = prefs.getString(getPrefPropName('quantity_type'));
        if (quantityType != null && quantityType.isNotEmpty) {
          defaultUnit = quantityType;
        }

        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle formInputTextStyle = TextStyle(fontSize: 14);

    String quantityType = defaultUnit;

    final theme = Theme.of(context);

    if (_isLoading) {
      // TODO : When loading, show the skeleton instead of the shrinked box.
      return const SizedBox.shrink();
    }

    return Form(
      key: _formKey,
      child: Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Name Input Field
            Text("Nom du produit", style: theme.textTheme.bodyText1),
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
                controller: nameInputController,
                style: theme.textTheme.bodyText1!.merge(formInputTextStyle),
                decoration: const InputDecoration(hintText: "Tomates")
                    .applyDefaults(theme.inputDecorationTheme),
                validator: (value) {
                  // Check if the string isn't empty.
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom d\'un produit';
                  }

                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),

            // Quantity Input Field
            Text("Quantité", style: theme.textTheme.bodyText1),
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: quantityInputController,
                      style:
                          theme.textTheme.bodyText1!.merge(formInputTextStyle),
                      decoration: const InputDecoration(
                        hintText: "0",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(3),
                            bottomLeft: Radius.circular(3),
                          ),
                          borderSide: BorderSide(),
                        ),
                      ).applyDefaults(theme.inputDecorationTheme),
                      validator: (value) {
                        // Checks if the field isn't empty and is a real number.
                        const errorMessage =
                            'Vous devez avoir au moins 1 produit.';

                        if (value == null) return errorMessage;

                        final intValue = num.tryParse(value);

                        if (intValue == null || intValue == 0) {
                          return errorMessage;
                        }

                        return null;
                      },
                    ),
                  ),
                  Flexible(
                    child: DropdownButtonFormField<String>(
                      style:
                          theme.textTheme.bodyText1!.merge(formInputTextStyle),
                      decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 7, horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(3),
                            bottomRight: Radius.circular(3),
                          ),
                        ),
                      ).applyDefaults(theme.inputDecorationTheme),
                      value: defaultUnit,
                      items: widget.units
                          .map((unit) => DropdownMenuItem<String>(
                                value: unit.slug,
                                child: Text(unit.name),
                              ))
                          .toList(),
                      onChanged: (String? value) async {
                        if (value != null) {
                          quantityType = value;
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Space
            const Spacer(),

            // Next Step Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Get the SharedPreferences instance and save all the values of the field.
                    final prefs = await SharedPreferences.getInstance();

                    await prefs.setInt(
                      getPrefPropName('quantity'),
                      int.parse(quantityInputController.text),
                    );

                    await prefs.setString(
                      getPrefPropName('name'),
                      nameInputController.text,
                    );

                    await prefs.setString(
                      getPrefPropName('quantity_type'),
                      quantityType,
                    );

                    widget.setNextState();
                  }
                },
                child: const Text('Choisir la catégorie'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
