import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;

class DBHelper {
  static Future<sql.Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, "stereo.db"),
        onCreate: (db, version) {
      return db.execute('''
       CREATE TABLE allSongs(
         id TEXT PRIMARY KEY,
         title TEXT,
         artist TEXT,
         album TEXT,
         albumArtist TEXT,
         albumArt BLOB,
         dateAdded TEXT,
         year TEXT,
         duration TEXT
       ) 
      ''');
    }, version: 1);
  }

  static Future<void> insert(String table, Map<String, dynamic> data) async {
    final db = await DBHelper.database();
    db.insert(table, data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await DBHelper.database();
    return db.query(table);
  }
}
