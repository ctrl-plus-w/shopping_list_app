import 'package:flutter/material.dart';

// Screens
import 'package:shopping_list_app/components/screens/favorite_products_screen.dart';
import 'package:shopping_list_app/components/screens/archived_lists_screen.dart';
import 'package:shopping_list_app/components/screens/new_product_popup.dart';
import 'package:shopping_list_app/components/screens/recipes_screen.dart';
import 'package:shopping_list_app/components/screens/home_screen.dart';

enum ScreensName {
  homeScreen,
  favoriteProductsScreen,
  archivedListsScreen,
  recipesScreen,
}

enum PopupsName {
  newProductPopup,
  archivedListPopup,
  editProductPopup,
  newRecipePopup,
}

const screens = <ScreensName, Widget>{
  ScreensName.homeScreen: HomeScreen(),
  ScreensName.favoriteProductsScreen: FavoriteProductsScreen(),
  ScreensName.archivedListsScreen: ArchivedListsScreen(),
  ScreensName.recipesScreen: RecipesScreen(),
};

const popups = <PopupsName, Widget>{
  PopupsName.newProductPopup: NewProductPopup(),
};

class ScreenManager extends ChangeNotifier {
  static ScreensName screenName = ScreensName.homeScreen;
  static PopupsName? popupName;

  get currentScreen => screens[screenName];
  get currentPopup => (popups[popupName] ?? Container());

  /// Open the given popup.
  void openPopup(PopupsName newPopupName) {
    popupName = newPopupName;

    notifyListeners();
  }

  /// Closes the current popup.
  void closePopup() {
    popupName = null;

    notifyListeners();
  }

  /// Change the screen.
  void setScreen(ScreensName newScreenName) {
    screenName = newScreenName;

    notifyListeners();
  }
}
