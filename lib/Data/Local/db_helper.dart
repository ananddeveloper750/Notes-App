import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final String TABLE_NAME = "noteDB";
  static final String TABLE_NOTE_TITLE = "mTitle";
  static final String TABLE_NOTE_DESC = "mDescription";
  static final String TABLE_NOTE_SR_NO = "mSrNo";

  ///Singleton
  DBHelper._();
  static final getInstance = DBHelper._();

  // db open(path -> if exist then open else create)
  Database? myDB;
  Future<Database> getDB() async {
    myDB ??= await openDB();
    return myDB!;
    // if(myDB!=null){
    //   return myDB!;
    // }
    // else{
    //   myDB=await openDB();
    //   return myDB!;
    // }
  }

  Future<Database> openDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDir.path, "noteDB");
    return await openDatabase(
      dbPath,
      onCreate: (db, version) {
        String tableCreateQueary =
            "create table $TABLE_NAME ($TABLE_NOTE_SR_NO integer primary key autoincrement, $TABLE_NOTE_TITLE text,$TABLE_NOTE_DESC text)";

        /// create your all table here
        db.execute(tableCreateQueary);
      },
      version: 1,
    );
  }

  /// all query

  /// add notes
  Future<bool> addNote({required String mTitle, required String mDesc}) async {
    var db = await getDB();
    int rowAffected = await db.insert(TABLE_NAME, {
      TABLE_NOTE_TITLE: mTitle,
      TABLE_NOTE_DESC: mDesc,
    });
    return rowAffected > 0;
  }

  /// reading notes
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    var db = await getDB();
    List<Map<String, dynamic>> mData = await db.query(TABLE_NAME);
    return mData;
  }

  Future<bool> updateNote({
    required String title,
    required String desc,
    required int sno,
  }) async {
    var db = await getDB();

    int rowAffected = await db.update(TABLE_NAME, {
      TABLE_NOTE_TITLE: title,
      TABLE_NOTE_DESC: desc,
    }, where: "$TABLE_NOTE_SR_NO=$sno");
    return rowAffected > 0;
  }

  Future<bool> deleteNote({required int index}) async {
    var db = await getDB();
    int rowAffected = await db.delete(
      TABLE_NAME,
      where: "$TABLE_NOTE_SR_NO=?",
      whereArgs: [index],
    );
    return rowAffected > 0;
  }
}
