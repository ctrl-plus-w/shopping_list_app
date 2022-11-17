import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

// Modules
import 'package:shopping_list_app/components/modules/product_category.dart';

// Elements
import 'package:shopping_list_app/components/elements/product.dart';

// Database
import 'package:shopping_list_app/states/cart_manager.dart';

// States
import 'package:shopping_list_app/states/screen_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final ButtonStyle settingsButtonStyle = ButtonStyle(
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      backgroundColor: MaterialStateProperty.all(Colors.white),
      shadowColor: MaterialStateProperty.all(Colors.transparent),
      minimumSize: MaterialStateProperty.all(Size.zero),
      padding: MaterialStateProperty.all(const EdgeInsets.all(7.5)),
      shape: MaterialStateProperty.all(
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          side: BorderSide(
            color: Color.fromRGBO(187, 195, 208, 1),
            width: 0.5,
          ),
        ),
      ),
    );

    return Consumer2<ScreenManager, CartManager>(
        builder: (context, screenManager, cartManager, child) {
      if (cartManager.isLoading) {
        return Scaffold(
          body: Container(
            padding: const EdgeInsets.all(16),
            child: const Text("Loading..."),
          ),
        );
      }

      return SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 48, left: 32, right: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Bienvenue !",
                    style: theme.textTheme.headline1,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4,
                          spreadRadius: 1,
                          offset: const Offset(1, 1),
                          color: Colors.black.withOpacity(0.09),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: settingsButtonStyle,
                      onPressed: () {},
                      child: SvgPicture.asset("assets/settings.svg"),
                    ),
                  ),
                ],
              ),
              Text(
                "Commencez vos courses.",
                style: theme.textTheme.subtitle1,
              ),
              const SizedBox(height: 21),
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(7.5),
                      backgroundColor: const Color.fromRGBO(33, 51, 67, 1),
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: () {},
                    child: Row(
                      children: [
                        const Text(
                          "Archiver / Supprimer",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 6),
                        SvgPicture.asset(
                          "assets/placeholder.svg",
                          height: 22,
                          width: 22,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              ListView.builder(
                itemCount: cartManager.categories.length,
                shrinkWrap: true,
                itemBuilder: ((context, index) => Column(
                      children: [
                        ProductCategory(
                          name: cartManager.categories.elementAt(index),
                          products: cartManager.products
                              .where(
                                (p) =>
                                    p.category != null &&
                                    p.category!.name ==
                                        cartManager.categories.elementAt(index),
                              )
                              .map(
                                (p) => Product(
                                  product: p,
                                  deleteDismissAction:
                                      cartManager.deleteProduct,
                                  favoriteDismissAction:
                                      cartManager.switchProductFavorite,
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
