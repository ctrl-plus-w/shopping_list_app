import 'package:shopping_list_app/database/database.dart';
import 'package:slugify/slugify.dart';
import 'package:sqflite/sqflite.dart';

const _tableName = "Unit";

class Unit {
  final int? id;
  final String name;

  String get slug => slugify(name);

  Unit({
    this.id,
    required this.name,
  });
  static List<Unit> fromList(List<String> units) {
    return List.generate(units.length, (index) => Unit(name: units[index]));
  }

  Map<String, Object?> toMap() {
    return {
      "slug": slug,
      "name": name,
    };
  }

  Future<void> insert(Database? database) async {
    database = (database ?? await DatabaseHelper.database);

    await database.insert(_tableName, toMap());
  }
}

Future<void> seedUnitTable(Database database) async {
  List<String> units = <String>["kg", "g", "unit"];

  for (String unit in units) {
    Unit(name: unit).insert(database);
  }
}

Future<void> createUnitTable(Database database) async {
  await database.execute("""
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY,
        slug VARCHAR(50) NOT NULL,
        name VARCHAR(50) NOT NULL
      );
      """);
}

Future<void> dropUnitTable(Database database) async {
  await DatabaseHelper.dropTable(database, _tableName);
}
