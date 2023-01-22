import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Modules
import 'package:shopping_list_app/components/screens/new_product_popup/category_step.dart';
import 'package:shopping_list_app/components/screens/new_product_popup/favorite_step.dart';
import 'package:shopping_list_app/components/screens/new_product_popup/general_step.dart';
import 'package:shopping_list_app/components/modules/popup_container.dart';

// Database
import 'package:shopping_list_app/database/models/category/category.dart';
import 'package:shopping_list_app/database/models/product/product.dart';
import 'package:shopping_list_app/database/models/cart/cart.dart';
import 'package:shopping_list_app/database/database.dart';

// Models
import 'package:shopping_list_app/helpers/navigation_automata.dart';
import 'package:shopping_list_app/database/models/unit/unit.dart';
import 'package:shopping_list_app/states/favorite_manager.dart';
import 'package:shopping_list_app/helpers/preferences.dart';
import 'package:shopping_list_app/states/cart_manager.dart';

const String pagePrefPrefix = "new_produt_page";
const String generalPrefPrefix = "general";
const String categoryPrefPrefix = "category";
const String favoritePrefPrefix = "favorite";

class NewProductPopup extends StatefulWidget {
  final bool skipFavoriteStep;
  final bool doNotAddToCart;

  const NewProductPopup({
    this.skipFavoriteStep = false,
    this.doNotAddToCart = false,
    Key? key,
  }) : super(key: key);

  @override
  State<NewProductPopup> createState() => _NewProductPopupState();
}

class _NewProductPopupState extends State<NewProductPopup> {
  late NavigationAutomata _state;

  List<Unit> _units = <Unit>[];
  List<Category> _categories = <Category>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _state = NavigationAutomata(States.general,
        skipFavoriteState: widget.skipFavoriteStep);

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

  Future<void> submit(Function refreshProducts) async {
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

    final bool isFavorite = widget.skipFavoriteStep
        ? true
        : (prefs.getBool(getPropName("enabled")) ?? false);

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
      checked: false,
    );

    if (!widget.doNotAddToCart) {
      final cart = await Cart.getOrCreateCurrent();
      await cart.addProduct(product);
    } else {
      await product.create();
    }

    // Clear the shared prefs
    prefs.clear();

    // Refresh the products before closing the popup
    await refreshProducts();

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

    return Consumer2<CartManager, FavoriteManager>(
      builder: (context, cartManager, favoriteManager, child) => PopupContainer(
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
                  pagePrefPrefix: pagePrefPrefix,
                )
              else if (_state.state == States.category)
                CategoryStepFormCategory(
                  categories: _categories,
                  setNextState: setNextState,
                  setPreviousState: setPreviousState,
                  skipFavoriteStep: widget.skipFavoriteStep,
                  pagePrefPrefix: pagePrefPrefix,
                  submit: () => submit(favoriteManager.refreshProducts),
                )
              else if (_state.state == States.favorite)
                FavoriteStepFormCategory(
                  setNextState: setNextState,
                  setPreviousState: setPreviousState,
                  pagePrefPrefix: pagePrefPrefix,
                  submit: () => submit(cartManager.refreshProducts),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
