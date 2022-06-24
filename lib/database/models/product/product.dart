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
    required this.id,
    required this.name,
    required this.quantity,
    required this.favorite,
    required this.unit,
  });
}

Future<void> createProductTable(Database database) async {
  await database.execute("""
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY,
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

Future<void> insertProduct(Product product) async {}
