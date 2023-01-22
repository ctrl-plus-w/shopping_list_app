import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

import 'package:shopping_list_app/components/screens/new_product_popup.dart';
import 'package:shopping_list_app/components/screens/new_recipe_popup.dart';
import 'package:shopping_list_app/components/screens/new_recipe_product_popup.dart';
import 'package:shopping_list_app/states/screen_manager.dart';

class DockedButton extends StatefulWidget {
  final ScreensName screenName;

  const DockedButton({Key? key, required this.screenName}) : super(key: key);

  @override
  State<DockedButton> createState() => _DockedButtonState();
}

class _DockedButtonState extends State<DockedButton> {
  static Route<Object?> _newProductPopupRouteBuilder(
    BuildContext context,
    Object? arguments,
  ) =>
      RawDialogRoute(
        pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return const NewProductPopup();
        },
      );

  static Route<Object?> _favoriteNewProductPopupRouteBuilder(
    BuildContext context,
    Object? arguments,
  ) =>
      RawDialogRoute(
        pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return const NewProductPopup(
            skipFavoriteStep: true,
            doNotAddToCart: true,
          );
        },
      );

  static Route<Object?> _newRecipePopupRouteBuilder(
    BuildContext context,
    Object? arguments,
  ) =>
      RawDialogRoute(
        pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return const NewRecipePopup();
        },
      );

  static Route<Object?> _newRecipeProductPopupRouteBuilder(
    BuildContext context,
    Object? arguments,
  ) =>
      RawDialogRoute(
        pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return const NewRecipeProductPopup();
        },
      );

  void handleClick() {
    final map = <ScreensName, Route<Object?> Function(BuildContext, Object?)>{
      ScreensName.homeScreen: _newProductPopupRouteBuilder,
      ScreensName.favoriteProductsScreen: _favoriteNewProductPopupRouteBuilder,
      ScreensName.recipesScreen: _newRecipePopupRouteBuilder,
      ScreensName.recipeScreen: _newRecipeProductPopupRouteBuilder,
    };

    if (map.keys.toList().contains(widget.screenName)) {
      Navigator.of(context).restorablePush(map[widget.screenName]!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: handleClick,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: const Color.fromRGBO(187, 195, 208, 1),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(32, 94, 187, 0),
              blurRadius: 1,
              offset: Offset(1, 1),
              spreadRadius: 0,
            )
          ],
        ),
        width: 60.0,
        height: 60.0,
        child: Align(
          child: SizedBox(
            width: 26,
            height: 26,
            child: SvgPicture.asset(
              "assets/add.svg",
            ),
          ),
        ),
      ),
    );
  }
}
