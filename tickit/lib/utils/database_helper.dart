import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:tickit/models/note.dart';

class DatabaseHelper {

  static DatabaseHelper _databaseHelper; //Singleton Databasehelper
  static Database _database;

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';

  DatabaseHelper.createInstance();

  factory DatabaseHelper() {
    if(_databaseHelper == null) {
      _databaseHelper = DatabaseHelper.createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {

    if(_database == null){
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {

    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';

    //open/create the database at given path
    var notesDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;

  }

  //Create DATABASE
  void _createDb(Database db, int newVersion) async {

    await db.execute("CREATE TABLE $noteTable ($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDescription TEXT, $colPriority INTEGER)");
  }

  //Fetch Operation: Get all note objects from the database
  Future<List<Map<String, dynamic>>> getNoteMapList( ) async {
    Database db = await this.database;

    var result = await db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }

  //Insert Operation: Insert a note object in a database
  Future<int> insertNote(Note note) async {
    Database db = await this.database;

    var result  = await db.insert(noteTable, note.toMap());
    return result;
  }

  //Update Operation: Update a note object and save it to database
  Future<int> updateNote(Note note) async {
    Database db =  await this.database;

    var result = await db.update(noteTable, note.toMap(), where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  //Delete Operation: Delete a note object from the database
  Future<int> deleteNote(int id)  async {
    var db = await this.database;
     int result = await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');
     return result;
  }

  //Get number of Note objects in database
  Future<int> getCount( ) async {
    Database db =  await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $noteTable');
    int result = Sqflite.firstIntValue(x);
    return  result;
  }

  //Get the 'Map List' [List<Map>] and convert it to 'Note List' [List<Note>]

  Future<List<Note>> getNoteList( ) async {

    var noteMapList = await getNoteMapList(); //Get 'Map List' from database
    int count = noteMapList.length;

    List<Note> noteList = List<Note>( );

    //for loop create note list from map list
    for(int i=0; i< count; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }



}