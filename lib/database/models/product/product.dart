import 'dart:developer';

import 'package:shopping_list_app/database/database.dart';
import 'package:shopping_list_app/database/models/category/category.dart';
import 'package:shopping_list_app/database/models/unit/unit.dart';
import 'package:sqflite/sqflite.dart';

const _tableName = "Product";

class Product {
  late int id;
  late Category? category;

  late String name;
  late int quantity;
  late bool favorite;
  late Unit unit;

  Product({
    this.id = -1,
    this.category,
    required this.name,
    required this.quantity,
    required this.favorite,
    required this.unit,
  });

  Product.fromMap(Map<String, Object?> map) {
    id = map["productId"] as int;
    name = map["productName"] as String;
    quantity = map["productQuantity"] as int;
    favorite = map["productIsFavorite"] == '0';

    category = Category(
      id: map['categoryId'] as int,
      name: map['categoryName'] as String,
      slug: map['categorySlug'] as String,
    );

    unit = Unit(
      id: map["unitId"] as int,
      name: map["unitName"] as String,
    );
  }

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

  Future<int> create(Database database) async {
    final productId = await database.insert(
      _tableName,
      toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );

    if (category != null && category?.id != null && category?.id != -1) {
      await database.insert('CategoryProduct', {
        "category_id": category!.id,
        "product_id": productId,
        "checked": 0,
      });
    }

    return productId;
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

String getTableName() {
  return _tableName;
}
