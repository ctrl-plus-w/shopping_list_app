import 'package:flutter/material.dart';

// Modules
import 'package:shopping_list_app/components/modules/bottom_navigation_bar.dart';

// Elements
import 'package:shopping_list_app/components/elements/docked_button.dart';

class FavoriteProductsScreen extends StatelessWidget {
  const FavoriteProductsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(64),
        child: const Text("Welcome on the favorite product page..."),
      ),
      bottomNavigationBar: const BottomNavigation(),
      floatingActionButton: const DockedButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
