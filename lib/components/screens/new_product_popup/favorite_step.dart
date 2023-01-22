import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

// Helpers
import 'package:shopping_list_app/helpers/preferences.dart';
import 'package:shopping_list_app/states/cart_manager.dart';

class FavoriteStepFormCategory extends StatefulWidget {
  final String pagePrefPrefix;
  final void Function() setNextState;
  final void Function() setPreviousState;

  final Future<void> Function() submit;

  const FavoriteStepFormCategory({
    Key? key,
    required this.setNextState,
    required this.setPreviousState,
    required this.submit,
    required this.pagePrefPrefix,
  }) : super(key: key);

  @override
  State<FavoriteStepFormCategory> createState() =>
      _FavoriteStepFormCategoryState();
}

class _FavoriteStepFormCategoryState extends State<FavoriteStepFormCategory> {
  late Function getPropName =
      prefPropNameGetter(widget.pagePrefPrefix, "favorite");

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<CartManager>(
      builder: (context, cartManager, child) => Expanded(
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
                  SvgPicture.asset('assets/favorite_illustration.svg'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          widget.submit();
                        },
                        child: const Text('Non merci.'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();

                          await prefs.setBool(getPropName('enabled'), true);

                          await widget.submit();

                          await cartManager.refreshProducts();
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
      ),
    );
  }
}
