import 'package:shopping_list_app/database/database.dart';
import 'package:shopping_list_app/database/models/product/product.dart';
import 'package:sqflite/sqflite.dart';

const _tableName = "Recipe";

class Recipe {
  final int id;
  final String name;
  final List<Product> products;

  Recipe({
    required this.id,
    required this.name,
    this.products = const [],
  });

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

  await database.execute("""
      CREATE TABLE RecipeCategory (
        recipe_id INTEGER,
        category_id INTEGER,
        FOREIGN KEY(recipe_id) REFERENCES Recipe(id),
        FOREIGN KEY(category_id) REFERENCES Category(id)
      );
      """);
}

Future<void> dropRecipeRelations(Database database) async {
  await DatabaseHelper.dropTable(database, "RecipeProduct");
  await DatabaseHelper.dropTable(database, "RecipeCategory");
}
