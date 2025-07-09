import 'package:magmentv101/features/common/task/modelclass.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'modelclass.dart';

class DBHelper {
  static Database? _database;

  // Initialize the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  // Initialize the database
  initDB() async {
    String path = join(await getDatabasesPath(), 'todo.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            taskDescription TEXT,
            startTime TEXT,
            endTime TEXT,
            isCompleted INTEGER
          )
        ''');
      },
    );
  }

  // Insert task into database
  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get tasks by date (the date is already selected in the app, so this fetches tasks based on the date selected)
  Future<List<Task>> getTasksByDate(DateTime selectedDate) async {
    final db = await database;

    List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'startTime LIKE ?',
      whereArgs: [selectedDate.toIso8601String().substring(0, 10) + '%'],
    );
    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  // Update task completion status
  Future<void> updateTaskCompletion(Task task) async {
    final db = await database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }
}
