import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Models
import 'package:shopping_list_app/database/models/unit/unit.dart';
import 'package:shopping_list_app/database/models/cart/cart.dart';
import 'package:shopping_list_app/database/models/category/category.dart';
import 'package:shopping_list_app/database/models/product/product.dart';
import 'package:shopping_list_app/database/models/recipe/recipe.dart';

Future<void> _onCreate(Database database, int version) async {
  await createCategoryTable(database); // ! Priority = 1
  await createRecipeTable(database); // ! Priority = 1
  await createUnitTable(database); // ! Priority = 1
  await createCartTable(database); // ! Priority = 1

  await createProductTable(database); // ! Priority = 2

  await createCategoryRelations(database); // ! Priority = 3
  await createRecipeRelations(database); // ! Priority = 3
  await createCartRelations(database); // ! Priority = 3

  await seedUnitTable(database); // ! Priority = 4
}

Future<void> _onUpgrade(
  Database database,
  int oldVersion,
  int newVersion,
) async {
  if (oldVersion < newVersion) {
    await dropCategoryRelations(database); // ! Priority = 1
    await dropRecipeRelations(database); // ! Priority = 1
    await dropCartRelations(database); // ! Priority = 1

    await dropProductTable(database); // ! Priority = 2

    await dropCategoryTable(database); // ! Priority = 3
    await dropRecipeTable(database); // ! Priority = 3
    await dropCartTable(database); // ! Priority = 3
    await dropUnitTable(database); // ! Priority = 3

    await _onCreate(database, newVersion);
  }
}

class DatabaseHelper {
  static Future<Database>? _database;

  static Future<Database> get database => _database ?? initDb();

  static Future<Database> initDb() async {
    WidgetsFlutterBinding.ensureInitialized();

    _database = openDatabase(
      join(await getDatabasesPath(), "shopping_list_database.db"),
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      version: 1,
    );

    return _database as Future<Database>;
  }

  static Future<void> dropTable(
    Database database,
    String tableName, {
    bool ifExists = true,
  }) async {
    await database
        .execute("DROP TABLE ${ifExists ? 'IF EXISTS ' : ''}$tableName");
  }
}
