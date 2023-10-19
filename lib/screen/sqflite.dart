import 'package:sqflite/sqflite.dart';

late Database db;
Future<void> initializeDatabase() async {
  db = await openDatabase(
    "cameraApplilication.db",
    version: 1,
    onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE camera (id INTEGER PRIMARY KEY AUTOINCREMENT,imagesrc TEXT)');
    },
  );
}

Future<void> addimageToDb(String imagesrc) async {
  await db.rawInsert('INSERT INTO camera(imagesrc) VALUES(?)', [imagesrc]);
}

Future<List<Map<String, dynamic>>> getimageFromdb() async {
  final value = await db.rawQuery('SELECT * FROM camera');
  return value;
}

Future<void> deleteImageFromDB(int id) async {
  await db.rawDelete('DELETE FROM camera WHERE id = ?', [id]);
}
