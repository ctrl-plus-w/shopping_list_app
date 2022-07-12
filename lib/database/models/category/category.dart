import 'package:shopping_list_app/database/database.dart';
import 'package:slugify/slugify.dart';
import 'package:sqflite/sqflite.dart';

const _tableName = "Category";

class Category {
  late int? id;
  late String slug;
  late String name;

  Category({
    required this.slug,
    required this.name,
    this.id,
  });

  Category.fromMap(Map<String, Object?> map) {
    slug = map['slug'] as String;
    name = map['name'] as String;
    id = map['id'] as int;
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, slug: $slug)';
  }

  static List<Category> toList(List<String> categories) {
    return List.generate(
      categories.length,
      (index) => Category(
        slug: slugify(categories[index]),
        name: categories[index],
      ),
    );
  }

  Map<String, Object?> toMap() {
    return {
      "id": id,
      "slug": slug,
      "name": name,
    };
  }

  static Future<List<Category>> getAll() async {
    final database = await DatabaseHelper.database;

    List<Map<String, Object?>> res = await database.query(
      _tableName,
      columns: ['id', 'slug', 'name'],
    );

    return res.map(Category.fromMap).toList();
  }

  Future<int> insert([Database? database]) async {
    database = (database ?? await DatabaseHelper.database);

    return await database.insert(_tableName, toMap());
  }
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
