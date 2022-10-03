import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Elements
import 'package:shopping_list_app/components/elements/bottom_navigation_bar_button.dart';

// States
import 'package:shopping_list_app/states/screen_manager.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  State<BottomNavigation> createState() => BottomNavigationState();
}

class BottomNavigationPainter extends CustomPainter {
  static double convertRadiusToSigma(double radius) => radius * 0.57735 + 0.5;

  @override
  void paint(Canvas canvas, Size size) {
    Paint strokePaint = Paint()
      ..color = const Color.fromRGBO(187, 195, 208, 1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    Paint fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Path path = Path();

    double arcDiameter = 77;
    double arcStartX = (size.width - 77) / 2;

    path.moveTo(0, 0);
    path.lineTo(arcStartX, 0);

    path.arcToPoint(
      Offset(arcStartX + arcDiameter, 0),
      radius: const Radius.circular(77 / 2),
      clockwise: false,
    );

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 0);

    path.close();

    canvas.drawShadow(path, Colors.black, 200, false);
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class BottomNavigationState extends State<BottomNavigation> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ScreenManager>(
      builder: (context, manager, child) => Container(
        height: 80,
        padding: const EdgeInsets.all(0),
        child: CustomPaint(
          painter: BottomNavigationPainter(),
          size: const Size.fromHeight(80),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              BottomNavigationBarButton(
                onPressed: () => manager.setScreen(ScreensName.homeScreen),
                iconPath: "assets/cart.svg",
                label: "Accueil",
              ),
              BottomNavigationBarButton(
                onPressed: () =>
                    manager.setScreen(ScreensName.favoriteProductsScreen),
                iconPath: "assets/favorite.svg",
                label: "Produits favoris",
              ),
              const SizedBox(width: 50),
              BottomNavigationBarButton(
                onPressed: () =>
                    manager.setScreen(ScreensName.archivedListsScreen),
                iconPath: "assets/archived.svg",
                label: "Listes Archivées",
              ),
              BottomNavigationBarButton(
                onPressed: () => manager.setScreen(ScreensName.recipesScreen),
                iconPath: "assets/recipes.svg",
                label: "Recettes",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
