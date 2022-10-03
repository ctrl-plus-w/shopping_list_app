import 'package:shopping_list_app/database/database.dart';
import 'package:slugify/slugify.dart';
import 'package:sqflite/sqflite.dart';

const _tableName = "Unit";

// TODO : Why isn't there the slug field on the class ?

class Unit {
  late int? id;
  late String name;

  String get slug => slugify(name);

  Unit({
    this.id,
    required this.name,
  });

  Unit.fromMap(Map<String, Object?> map) {
    if (map['id'] != null) id = int.tryParse(map['id'] as String);

    name = map['name'] as String;
  }

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

  static Future<Unit?> getByName(String name) async {
    final database = await DatabaseHelper.database;

    List<Map<String, dynamic>> units = await database.query(
      _tableName,
      columns: ['id', 'name'],
      where: 'name = "$name"',
    );

    if (units.isNotEmpty) {
      final unit = units[0];
      return Unit(name: unit['name'], id: unit['id']);
    }

    return null;
  }

  /// Retrieve all the units.
  static Future<List<Unit>> getAll() async {
    final database = await DatabaseHelper.database;

    List<Map<String, dynamic>> res = await database.query(
      _tableName,
      columns: ['id', 'name'],
    );

    return res
        .map((unit) => Unit(
              id: unit['id'],
              name: unit['name'],
            ))
        .toList();
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

String getTableName() {
  return _tableName;
}
