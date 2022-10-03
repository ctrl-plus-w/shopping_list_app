import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

// Modules
import 'package:shopping_list_app/components/modules/product_category.dart';

// Elements
import 'package:shopping_list_app/components/elements/product.dart';

// Database
import 'package:shopping_list_app/database/database.dart';
import 'package:shopping_list_app/database/models/cart/cart.dart';

// States
import 'package:shopping_list_app/states/screen_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Cart? cart;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    DatabaseHelper.database.whenComplete(() async {
      final currentCart = await Cart.getOrCreateCurrent();

      setState(() {
        cart = currentCart;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Container(
          padding: const EdgeInsets.all(16),
          child: const Text("Loading..."),
        ),
      );
    }

    final theme = Theme.of(context);

    // TODO : Make the SettingsButton shadow. (Also maybe make this button a component.)

    final ButtonStyle settingsButtonStyle = ButtonStyle(
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

    return Consumer<ScreenManager>(
      builder: (context, manager, child) => SingleChildScrollView(
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
                  ElevatedButton(
                    style: settingsButtonStyle,
                    onPressed: () {},
                    child: SvgPicture.asset("assets/settings.svg"),
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
                      // TODO : Make the shadow.
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

              // First product category (without label)
              ...const [
                Product(name: "Papier toilette"),
                SizedBox(height: 9),
                Product(name: "Canard WC"),
                SizedBox(height: 9),
                Product(name: "Sopalin"),
                SizedBox(height: 36),
              ],

              // Second product category
              const ProductCategory(
                name: "Fruits & Légumes",
                products: [
                  Product(name: "Fraises"),
                  Product(name: "Tomates", unit: Units.g, quantity: 300),
                  Product(name: "Pommes", unit: Units.g, quantity: 500),
                  Product(name: "Poires", unit: Units.kg),
                ],
              ),
              const SizedBox(height: 36),

              // Third product category
              const ProductCategory(
                name: "Viande",
                products: [
                  Product(
                    name: "Cuisses de poulet",
                    unit: Units.g,
                    quantity: 300,
                  ),
                  Product(
                    name: "Boeuf haché",
                    unit: Units.g,
                    quantity: 400,
                    striked: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
