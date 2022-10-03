import 'package:flutter/material.dart';

// Screens
import 'package:shopping_list_app/components/screens/favorite_products_screen.dart';
import 'package:shopping_list_app/components/screens/archived_lists_screen.dart';
import 'package:shopping_list_app/components/screens/recipes_screen.dart';
import 'package:shopping_list_app/components/screens/home_screen.dart';

enum ScreensName {
  homeScreen,
  favoriteProductsScreen,
  archivedListsScreen,
  recipesScreen,
}

const screens = <ScreensName, Widget>{
  ScreensName.homeScreen: HomeScreen(),
  ScreensName.favoriteProductsScreen: FavoriteProductsScreen(),
  ScreensName.archivedListsScreen: ArchivedListsScreen(),
  ScreensName.recipesScreen: RecipesScreen(),
};

class ScreenManager extends ChangeNotifier {
  static ScreensName screenName = ScreensName.homeScreen;

  get currentScreen => screens[screenName];
  get currentScreenName => screenName;

  /// Change the screen.
  void setScreen(ScreensName newScreenName) {
    screenName = newScreenName;

    notifyListeners();
  }
}
