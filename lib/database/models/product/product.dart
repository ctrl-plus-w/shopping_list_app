import 'package:shopping_list_app/database/database.dart';
import 'package:shopping_list_app/database/models/unit/unit.dart';
import 'package:sqflite/sqflite.dart';

const _tableName = "Product";

class Product {
  final int id;
  final String name;
  final int quantity;
  final bool favorite;
  final Unit unit;

  Product({
    this.id = -1,
    required this.name,
    required this.quantity,
    required this.favorite,
    required this.unit,
  });

  Map<String, dynamic> toMap({bool withId = false}) {
    final map = {
      "name": name,
      "quantity": quantity,
      "favorite": favorite ? 1 : 0,
      "unit_id": unit.id,
    };

    if (withId) {
      map['id'] = id;
    }

    return map;
  }

  Future<void> create(Database database) async {
    await database.insert(
      _tableName,
      toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }
}

Future<void> createProductTable(Database database) async {
  await database.execute("""
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR(50)NOT NULL,
        quantity INTEGERNOT NULL,
        favorite INTEGER NOT NULL,
        unit_id INTEGERNOT NULL,
        FOREIGN KEY(unit_id) REFERENCES Unit(id)
      );
      """);
}

Future<void> dropProductTable(Database database) async {
  await DatabaseHelper.dropTable(database, _tableName);
}

Future<int> createProduct(Database database, Product product) async {
  final database = await DatabaseHelper.database;

  final productId = await database.insert(
    _tableName,
    product.toMap(),
    conflictAlgorithm: ConflictAlgorithm.fail,
  );

  return productId;
}
