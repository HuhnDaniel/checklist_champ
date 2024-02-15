import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:checklist_champ/model/task.dart';

// class DatabaseHandler {
//   Future<Database> initializeDB() async {
//     final database = openDatabase(
//       join(await getDatabasesPath(), 'checklist_champ.db'),
//       onCreate: (db, version) {
//         return db.execute(
//           'CREATE TABLE tasks(id INTEGER PRIMARY KEY, name TEXT, description TEXT, value INTEGER)',
//         );
//       },
//       version: 1,
//     );

//     return database;
//   }
// }

class DatabaseHandler {
  Database? db;

  Future<Database> get database async {
    if (db != null) {
      return db!;
    }

    db = await initializeDB();
    return db!;
  }

  Future<String> get fullPath async {
    const name = 'checklist_champ.db';
    final path = await getDatabasesPath();
    return join(path, name);
  }

  Future<Database> initializeDB() async {
    final path = await fullPath;
    var database = await openDatabase(
      path,
      version: 1,
      onCreate: create,
      singleInstance: true,
    );

    return database;
  }

  Future<void> create(Database database, int version) async =>
      await TaskDB().createTable(database);
}

class TaskDB {
  final tableName = 'tasks';

  Future<void> createTable(Database database) async {
    await database.execute('''CREATE TABLE IF NOT EXISTS $tableName(
      "id" INTEGER NOT NULL,
      "name" TEXT NOT NULL,
      "description" TEXT NOT NULL,
      "value" INTEGER NOT NULL,
      PRIMARY KEY("id" AUTOINCREMENT)
    );''');
  }

  Future<int> create(
      {required String name,
      required String description,
      required int value}) async {
    final database = await DatabaseHandler().database;

    return await database.rawInsert(
      '''INSERT INTO $tableName (name, description, value) VALUES (?,?,?)''',
      [name, description, value],
    );
  }

  Future<List<Task>> fetchAll() async {
    final database = await DatabaseHandler().database;
    final tasks = await database.rawQuery('''SELECT * FROM $tableName''');

    return tasks.map((task) => Task.fromSqfliteDatabase(task)).toList();
  }
}
