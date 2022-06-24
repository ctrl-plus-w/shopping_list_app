import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_list_app/components/screens/new_product_popup.dart';
import 'package:shopping_list_app/database/database.dart';

// States
import 'package:shopping_list_app/states/screen_manager.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => ScreenManager(),
    child: const MyApp(),
  ));
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
          backgroundColor:
              MaterialStateProperty.all(const Color.fromRGBO(33, 51, 67, 1)),
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
        subtitle1: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Color.fromRGBO(107, 121, 134, 1),
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
            home: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                screenManager.currentScreen,
                const TemporaryWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TemporaryWidget extends StatelessWidget {
  const TemporaryWidget({Key? key}) : super(key: key);

  static Route<Object?> _routeBuilder(BuildContext context, Object? arguments) {
    return RawDialogRoute(
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return const NewProductPopup();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OutlinedButton(
        onPressed: () {
          Navigator.of(context).restorablePush(_routeBuilder);
        },
        child: const Text('Open dialog'),
      ),
    );
  }
}
