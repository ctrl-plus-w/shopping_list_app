import 'package:shopping_list_app/database/database.dart';
import 'package:sqflite/sqflite.dart';

const _tableName = "Category";

class Category {
  final int id;
  final String slug;
  final String name;

  Category({
    required this.id,
    required this.slug,
    required this.name,
  });
}

Future<void> createCategoryTable(Database database) async {
  await database.execute("""
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY,
        slug VARCHAR(50) NOT NULL,
        name VARCHAR(50) NOT NULL
      );
      """);
}

Future<void> dropCategoryTable(Database database) async {
  await DatabaseHelper.dropTable(database, _tableName);
}

Future<void> createCategoryRelations(Database database) async {
  await database.execute("""
      CREATE TABLE CategoryProduct (
        checked INTEGER NOT NULL,
        category_id INTEGER,
        product_id INTEGER,
        FOREIGN KEY(category_id) REFERENCES $_tableName(id),
        FOREIGN KEY(product_id) REFERENCES Product(id)
      );
      """);
}

Future<void> dropCategoryRelations(Database database) async {
  await DatabaseHelper.dropTable(database, "CategoryProduct");
}
