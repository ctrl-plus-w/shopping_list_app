import 'package:shopping_list_app/database/database.dart';
import 'package:shopping_list_app/database/models/cart/cart.dart';
import 'package:sqflite/sqflite.dart';

import 'package:shopping_list_app/database/models/category/category.dart';
import 'package:shopping_list_app/database/models/unit/unit.dart';

import 'package:shopping_list_app/database/models/product/product.dart'
    as product_model show getTableName;
import 'package:shopping_list_app/database/models/category/category.dart'
    as category_model show getTableName;
import 'package:shopping_list_app/database/models/unit/unit.dart' as unit_model
    show getTableName;

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
    favorite = map["productIsFavorite"] == 1;

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

  Future<void> updateQuantity(int quantity) async {
    final database = await DatabaseHelper.database;

    await database.update(
      _tableName,
      {"quantity": quantity},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateFavoriteState(bool state) async {
    final database = await DatabaseHelper.database;

    await database.update(
      _tableName,
      {"favorite": state ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> addToFavorite() {
    return updateFavoriteState(true);
  }

  Future<void> removeFromFavorite() {
    return updateFavoriteState(false);
  }

  Future<bool> delete() async {
    final database = await DatabaseHelper.database;

    final productDeleted = await database.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    return productDeleted > 0;
  }

  Future<bool> deleteFromMainCart() async {
    final database = await DatabaseHelper.database;

    /// Returns this shape :
    /// [{RecipeCount: int, CartCount: int}]
    ///
    final res = await database.rawQuery('''
      SELECT * FROM
      (
        SELECT COUNT(*) as recipeCount FROM RecipeProduct
          WHERE RecipeProduct.product_id = $id
      ),
      (
        SELECT COUNT(*) as cartCount FROM CartProduct
          JOIN Cart ON CartProduct.cart_id = Cart.id  
        WHERE CartProduct.product_id = $id
          AND Cart.archived = 1
      );
    ''');

    // The amount of recipe where the product is in
    int recipeCount = res[0]['recipeCount'] as int;

    // The amount of carts where the product is in (archived carts)
    int cartCount = res[0]['cartCount'] as int;

    int deleteCount = 0;

    if (favorite || recipeCount > 0 || cartCount > 0) {
      final cart = await Cart.getOrCreateCurrent();

      deleteCount = await database.delete(
        'CartProduct',
        where: 'product_id = ? AND cart_id = ?',
        whereArgs: [id, cart.id],
      );
    } else {
      deleteCount = await database.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    }

    return deleteCount > 0;
  }

  @override
  String toString() {
    return "Product(id: $id, name: $name, quantity: $quantity, unit: ${unit.name}, category: ${category?.name ?? 'null'}, favorite: $favorite)";
  }

  static Future<List<Product>> getAll(
      {bool favorite = false, List<int> ids = const []}) async {
    final database = await DatabaseHelper.database;

    final productTableName = product_model.getTableName();
    final categoryTableName = category_model.getTableName();
    final unitTableName = unit_model.getTableName();

    final query = ('''
      SELECT
        $productTableName.id as productId,
        $productTableName.name as productName,
        $productTableName.quantity as productQuantity, 
        $productTableName.favorite as productIsFavorite,
        
        $categoryTableName.name as categoryName,
        $categoryTableName.id as categoryId,
        $categoryTableName.slug as categorySlug,

        $unitTableName.name as unitName,
        $unitTableName.id as unitId,
        $unitTableName.slug as unitSlug
      FROM
        $_tableName
      LEFT JOIN CategoryProduct
        ON CategoryProduct.product_id = $_tableName.id
      LEFT JOIN $categoryTableName
        ON CategoryProduct.category_id = $categoryTableName.id 
      LEFT JOIN $unitTableName
        ON $_tableName.unit_id = $unitTableName.id
      WHERE
        $_tableName.id ${ids.isEmpty ? "IS NOT NULL" : "IN (${ids.join(',')})"}
        ${favorite ? "AND $_tableName.favorite = 1" : ""};
      ''');

    final products = await database.rawQuery(query);

    return products.map(Product.fromMap).toList();
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
