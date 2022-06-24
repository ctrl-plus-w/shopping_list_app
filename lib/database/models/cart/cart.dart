import 'package:sqflite/sqflite.dart';

// Helpers
import 'package:shopping_list_app/helpers/convert.dart';

// Database
import 'package:shopping_list_app/database/database.dart';

const _tableName = "Cart";

class Cart {
  int? id;
  String? name;
  bool archived;
  bool deleted;

  Cart({this.id, this.name, this.archived = false, this.deleted = false});

  /// Convert the Cart instance into a string
  @override
  String toString() {
    return 'Cart(id: $id, name: $name, archived: $archived, deleted: $deleted)';
  }

  /// Insert the Cart instance into the Database
  ///
  /// First checks if a cart with the same name and not deleted exists. If so,
  /// it returns an [Exception], otherwise it will create it and update the Cart
  /// instance id.
  Future<void> create() async {
    final database = await DatabaseHelper.database;

    final res = await database.rawQuery('''
      SELECT COUNT(*) FROM $_tableName WHERE
        $_tableName.deleted = 0 AND
        $_tableName.name = $name;
    ''');

    if (Sqflite.firstIntValue(res) != 0) {
      throw Exception("A Cart with this name already exists.");
    }

    id = await database.insert(_tableName, {
      "name": name,
      "archived": boolToInt(archived),
      "deleted": boolToInt(archived),
    });
  }

  /// Retrieve all the carts (not deleted).
  static Future<List<Cart>> getAll() async {
    final database = await DatabaseHelper.database;

    List<Map<String, dynamic>> res = await database.query(
      _tableName,
      columns: ['id', 'name', 'archived', 'deleted'],
      where: 'deleted = 0',
    );

    return res
        .map((cart) => Cart(
              id: cart['id'],
              name: cart['name'],
              archived: cart['archived'],
              deleted: cart['deleted'],
            ))
        .toList();
  }

  /// Retrieve the current cart.
  ///
  /// The current cart is the one displayed on the home page, he is neither
  /// deleted neither archived. Because he isn't archived he doesn't have any
  /// name.
  static Future<Cart?> getCurrent() async {
    final database = await DatabaseHelper.database;

    List<Map<String, dynamic>> res = await database.query(
      _tableName,
      columns: ['id', 'name', 'archived', 'deleted'],
      where: [
        '$_tableName.deleted = 0',
        '$_tableName.archived = 0',
        '$_tableName.name is NULL'
      ].join(' AND '),
    );

    if (res.isEmpty) return null;

    Map<String, dynamic> cart = res.first;

    return Cart(
      id: cart['id'],
      name: cart['name'],
      archived: intToBool(cart['archived']),
      deleted: intToBool(cart['deleted']),
    );
  }

  /// Retrieve the current cart, if he doesn't exists, create and return it.
  ///
  /// Call the [getCurrent()] method to check if the current cart is null. If so
  /// return it directly, otherwise, create it with the [cart.create()] method.
  static Future<Cart> getOrCreateCurrent() async {
    Cart? currentCart = await getCurrent();
    if (currentCart != null) return currentCart;

    Cart cart = Cart(archived: false, deleted: false);

    await cart.create();
    return cart;
  }
}

/// Create the cart table.
Future<void> createCartTable(Database database) async {
  await database.execute("""
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY,
        name VARCHAR(50),
        archived INTEGER NOT NULL,
        deleted INTEGER DEFAULT 0 NOT NULL
      );
      """);
}

/// Drop the cart table.
Future<void> dropCartTable(Database database) async {
  await DatabaseHelper.dropTable(database, _tableName);
}

/// Create the cart relations tables.
Future<void> createCartRelations(Database database) async {
  await database.execute("""
      CREATE TABLE CartProduct (
        cart_id INTEGER,
        product_id INTEGER,
        FOREIGN KEY(cart_id) REFERENCES $_tableName(id),
        FOREIGN KEY(product_id) REFERENCES Product(id)
      );
      """);

  await database.execute("""
      CREATE TABLE CartCategory (
        cart_id INTEGER,
        category_id INTEGER,
        FOREIGN KEY(cart_id) REFERENCES $_tableName(id),
        FOREIGN KEY(category_id) REFERENCES Category(id)
      );
      """);
}

/// Drop the cart relations tables.
Future<void> dropCartRelations(Database database) async {
  await DatabaseHelper.dropTable(database, "CartProduct");
  await DatabaseHelper.dropTable(database, "CartCategory");
}
