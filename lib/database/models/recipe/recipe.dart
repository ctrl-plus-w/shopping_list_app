import 'package:shopping_list_app/database/database.dart';
import 'package:shopping_list_app/database/models/product/product.dart';
import 'package:sqflite/sqflite.dart';

const _tableName = "Recipe";

class Recipe {
  late int id;
  late String name;
  late List<Product> products;

  Recipe({
    this.id = -1,
    this.products = const [],
    required this.name,
  });

  Map<String, dynamic> toMap({bool withId = false}) {
    final map = <String, dynamic>{
      "name": name,
    };

    if (withId) {
      map['id'] = id;
    }

    return map;
  }

  Future<int> create() async {
    final database = await DatabaseHelper.database;

    final productId = await database.insert(
      _tableName,
      toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );

    return productId;
  }

  Future<void> update() async {
    final database = await DatabaseHelper.database;

    await database.update(
      _tableName,
      toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> addProducts(List<Product> products) async {
    final database = await DatabaseHelper.database;

    final values = products.map((p) => "($id, ${p.id})").join(', ');

    await database.rawInsert(
        "INSERT INTO RecipeProduct(recipe_id, product_id) VALUES $values");
  }

  static Future<List<Recipe>> getAll() async {
    final database = await DatabaseHelper.database;

    final recipeRes = await database.query(_tableName);

    List<Recipe> recipes = <Recipe>[];

    for (final recipe in recipeRes) {
      final id = recipe['id'] as int;
      final name = recipe['name'] as String;

      final recipeProductsId = (await database.query(
        'RecipeProduct',
        where: 'RecipeProduct.recipe_id = ?',
        whereArgs: [id],
      ))
          .map((res) => res['product_id'] as int)
          .toList();

      final products = await Product.getAll(ids: recipeProductsId);

      recipes.add(Recipe(id: id, name: name, products: products));
    }

    return recipes;
  }
}

Future<void> createRecipeTable(Database database) async {
  await database.execute("""
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY,
        name VARCHAR(50) NOT NULL
      );
      """);
}

Future<void> dropRecipeTable(Database database) async {
  await DatabaseHelper.dropTable(database, _tableName);
}

Future<void> createRecipeRelations(Database database) async {
  await database.execute("""
      CREATE TABLE RecipeProduct (
        recipe_id INTEGER,
        product_id INTEGER,
        FOREIGN KEY(recipe_id) REFERENCES Recipe(id),
        FOREIGN KEY(product_id) REFERENCES Product(id)
      );
      """);
}

Future<void> dropRecipeRelations(Database database) async {
  await DatabaseHelper.dropTable(database, "RecipeProduct");
}
