import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Elements
import 'package:shopping_list_app/components/elements/docked_button.dart';

// Database
import 'package:shopping_list_app/database/database.dart';
import 'package:shopping_list_app/components/modules/bottom_navigation_bar.dart';

// States
import 'package:shopping_list_app/states/cart_manager.dart';
import 'package:shopping_list_app/states/favorite_manager.dart';
import 'package:shopping_list_app/states/recipe_manager.dart';
import 'package:shopping_list_app/states/screen_manager.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ScreenManager()),
        ChangeNotifierProvider(create: (context) => CartManager()),
        ChangeNotifierProvider(create: (context) => FavoriteManager()),
        ChangeNotifierProvider(create: (context) => RecipeManager()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = "Shopping List App";

  ThemeData _customTheme() {
    return ThemeData(
      backgroundColor: const Color.fromRGBO(250, 252, 255, 1),
      fontFamily: "Sora",
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor:
              MaterialStateProperty.all(const Color.fromRGBO(107, 121, 134, 1)),
          textStyle: MaterialStateProperty.all(const TextStyle(
            fontFamily: 'Sora',
            fontSize: 16,
          )),
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
          padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(vertical: 4, horizontal: 12)),
          shape: MaterialStateProperty.all(
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(3)),
            ),
          ),
        ),
      ),
      textTheme: const TextTheme(
        bodyText1: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Color.fromRGBO(33, 51, 67, 1),
        ),
        headline1: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          color: Color.fromRGBO(33, 51, 67, 1),
        ),
        headline2: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Color.fromRGBO(33, 51, 67, 1),
        ),
        headline3: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color.fromRGBO(33, 51, 67, 1),
        ),
        subtitle1: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Color.fromRGBO(107, 121, 134, 1),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        // Color
        filled: true,
        fillColor: Colors.white,

        // Border
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(3)),
          borderSide: BorderSide(
            color: Color.fromRGBO(187, 195, 208, 1),
            width: 0.2,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(3)),
          borderSide: BorderSide(
            color: Color.fromRGBO(187, 195, 208, 1),
            width: 0.2,
          ),
        ),

        // Hint
        hintStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Color.fromRGBO(107, 121, 134, 1),
        ),

        // Paddding
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color.fromRGBO(33, 51, 67, 1),
          textStyle: const TextStyle(
            fontSize: 16,
            fontFamily: 'Sora',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shadowColor: Colors.transparent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DatabaseHelper.initDb();

    return Consumer<ScreenManager>(
      builder: (context, screenManager, child) => Material(
        child: Material(
          child: MaterialApp(
            title: _title,
            theme: _customTheme(),
            home: Scaffold(
              body: screenManager.currentScreen,
              bottomNavigationBar: const BottomNavigation(),
              floatingActionButton:
                  DockedButton(screenName: screenManager.currentScreenName),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
            ),
          ),
        ),
      ),
    );
  }
}
