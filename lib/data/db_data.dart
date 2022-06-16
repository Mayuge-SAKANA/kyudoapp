import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyodoapp/data/data_sankasha_entity.dart';
import 'package:kyodoapp/data/data_sha_entity.dart';
import 'package:kyodoapp/data/data_tachi_object.dart';
import 'data_gyosha_object.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'data_define.dart';


class RecordDB {
  final String dbPath;

  RecordDB({this.dbPath = "data_db.db"}){
    //deleteDatabase(dbPath);
  }

  Future<Database> get gyoshaDatabase async {
    // openDatabase() データベースに接続
    final Future<Database> _database = openDatabase(
      // getDatabasesPath() データベースファイルを保存するパス取得
      join(await getDatabasesPath(), dbPath),
      onCreate: (db, version) {
        db.execute(
          // テーブルの作成
          "CREATE TABLE gyosha_data(id INTEGER PRIMARY KEY AUTOINCREMENT,"+
            "gyoshaID TEXT,"+
            "mainEditorName TEXT,"+
            "gyoshaState INTEGER,"+
            "gyoshaName  TEXT,"+
            "gyoshaType  INTEGER,"+
            "startYear INTEGER,"+
            "startMonth INTEGER,"+
            "startDay INTEGER,"+
            "startHour INTEGER,"+
            "startMinute INTEGER,"+
            "finishYear INTEGER,"+
            "finishMonth INTEGER,"+
            "finishDay INTEGER,"+
            "finishHour INTEGER,"+
            "finishMinute INTEGER,"+
            "memoText TEXT"+
            ");"
        );
        
          db.execute(
            // テーブルの作成
              "CREATE TABLE sankasha_data(id INTEGER PRIMARY KEY AUTOINCREMENT," +
                  "sankashaID TEXT," +
                  "gyoshaID TEXT," +
                  "sankashaName TEXT," +
                  "isAppUser INTEGER," +
                  "sankashaNumber INTEGER"
                      ");"
          );


        db.execute(
          // テーブルの作成
            "CREATE TABLE tachi_data(id INTEGER PRIMARY KEY AUTOINCREMENT,"+
                "tachiID TEXT,"+
                "tachiNumber INTEGER,"+
                "gyoshaID TEXT,"+
                "sankashaID TEXT"
                    ");"
        );

        db.execute(
          // テーブルの作成
            "CREATE TABLE sharesult_data(id INTEGER PRIMARY KEY AUTOINCREMENT,"+
                "shaID TEXT,"+
                "shaNumber INTEGER,"+
                "shaResult INTEGER,"+
                "tachiID TEXT"
                    ")"
        );
      },
      version: 1,
    );
    return _database;
  }


  Future<void> insertGyoshaData(GyoshaDataObj gyoshaDataObj) async {
    final db = await gyoshaDatabase;

    await db.insert(
      'gyosha_data',
      gyoshaDataObj.gyoshaData.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    for(TachiDataObj tachiDataObj in gyoshaDataObj.tachiList){
      await db.insert(
        'tachi_data',
        tachiDataObj.tachiData.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      for(ShaData shaData in tachiDataObj.shaList){
        await db.insert(
          'sharesult_data',
          shaData.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    for(SankashaData sankashaData in gyoshaDataObj.sankashaList){
      await db.insert(
        'sankasha_data',
        sankashaData.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  GyoshaDataObj getGyoshaDataObjFromMap(Map<String, dynamic> map){
    DateTime startDateTime = DateTime(
      map['startYear']??0,
      map['startMonth']??0,
      map['startDay']??0,
      map['startHour']??0,
      map['startMinutes']??0,
    );
    DateTime finishDateTime = DateTime(
      map['finishYear']??0,
      map['finishMonth']??0,
      map['finishDay']??0,
      map['finishHour']??0,
      map['finishMinutes']??0,
    );

    GyoshaDataObj gyoshaDataObj = GyoshaDataObj(
        map['mainEditorName'],
        map['gyoshaName'],
        GyoshaType.values[map['gyoshaType']],
        startDateTime,finishDateTime,
        gyoshaState: GyoshaState.values[map['gyoshaState']],
        memoText: map['memoText']??"",
        gyoshaID:map['gyoshaID'],
        newFlag: false,
    );
    return gyoshaDataObj;

  }

  Future<List<GyoshaDataObj>> getGyoshaDataObjList() async {
    final db = await gyoshaDatabase;
    final List<Map<String, dynamic>> maps = await db.query('gyosha_data');
    final List<GyoshaDataObj> newList = [];


    if(maps!=[]){
      for(var map in maps){
        var gyoshaDataObj = getGyoshaDataObjFromMap(map);
        newList.add(gyoshaDataObj);
          final List<Map<String, dynamic>> sankashaMaps = await db.query(
              "sankasha_data",
              where: "gyoshaID=?",
              whereArgs: [map['gyoshaID']]
          );

          if (sankashaMaps != []) {
            for (var sankashaMap in sankashaMaps) {
              SankashaData sankashaData = SankashaData(
                  sankashaMap['sankashaID'],
                  sankashaMap['gyoshaID'],
                  sankashaMap['isAppUser'] == 1 ? true : false,
                  sankashaName: sankashaMap['sankashaName'],
                  sankashaNumber: sankashaMap['sankashaNumber']
              );

              gyoshaDataObj.sankashaList.add(sankashaData);
            }
          }

          final List<Map<String, dynamic>> tachiMaps = await db.query(
              "tachi_data",
              where: "gyoshaID=?",
              whereArgs: [map['gyoshaID']]);

          if(tachiMaps!=[]) {
            for (var tachiMap in tachiMaps) {
              String sankashaID = tachiMap['sankashaID'];
              SankashaData sankashaData = gyoshaDataObj.sankashaList.firstWhere(
                      (element) => element.sankashaID == sankashaID);

              TachiDataObj tachiDataObj = TachiDataObj(
                  tachiMap['tachiID'],
                  tachiMap['gyoshaID'],
                  sankashaData,
                  tachiNumber: tachiMap['tachiNumber']);

              gyoshaDataObj.tachiList.add(tachiDataObj);

              final List<Map<String, dynamic>> shaMaps = await db.query(
                  "sharesult_data",
                  where: "tachiID=?",
                  whereArgs: [tachiMap['tachiID']]);


              if (shaMaps != []) {
                for (var shaMap in shaMaps) {
                  ShaData shaData = ShaData(
                      shaMap['shaID'],
                      shaMap['shaNumber'],
                      ShaResultType.values[shaMap['shaResult']],
                      shaMap['tachiID']
                  );
                  tachiDataObj.shaList.add(shaData);
                }
              }
            }
          }
      }
    }
    return newList;
  }

  Future<List<String>> getTableNames(DatabaseExecutor db) async {
    var tableNames = (await db
        .query('sqlite_master', where: 'type = ?', whereArgs: ['table']))
        .map((row) => row['name'] as String)
        .toList(growable: false)
      ..sort();
    return tableNames;
  }
  //再起動するたびにインスタンスカウントがリセットされている問題がある
  Future<void> updateGyoshaData(GyoshaDataObj gyoshaDataObj) async {
    // Get a reference to the database.
    final db = await gyoshaDatabase;

    await db.update(
      'gyosha_data',
      gyoshaDataObj.gyoshaData.toMap(),
      where: "gyoshaID = ?",
      whereArgs: [gyoshaDataObj.gyoshaID],
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
    int i=0;
    for(TachiDataObj tachiDataObj in gyoshaDataObj.tachiList) {

      final List<Map<String, dynamic>> tachiMaps = await db.query(
          "tachi_data",
          where: "tachiID=?",
          whereArgs: [tachiDataObj.tachiID]);

      if(tachiMaps.isEmpty){
        await db.insert(
          'tachi_data',
          tachiDataObj.tachiData.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }else{
        var num = await db.update(
          'tachi_data',
          tachiDataObj.tachiData.toMap(),
          where: "tachiID = ?",
          whereArgs: [tachiDataObj.tachiID],
          conflictAlgorithm: ConflictAlgorithm.fail,
        );
      }


      for(ShaData shaData in tachiDataObj.shaList){
        final List<Map<String, dynamic>> shaMaps = await db.query(
            "sharesult_data",
            where: "shaID=?",
            whereArgs: [shaData.shaID]);
        if(shaMaps.isEmpty){
          await db.insert(
            'sharesult_data',
            shaData.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }else{
          await db.update(
            'sharesult_data',
            shaData.toMap(),
            where: "shaID = ?",
            whereArgs: [shaData.shaID],
            conflictAlgorithm: ConflictAlgorithm.fail,
          );
        }
      }
    }
    for(SankashaData sankashaData in gyoshaDataObj.sankashaList){
      final List<Map<String, dynamic>> sankashaMaps = await db.query(
          "sankasha_data",
          where: "sankashaID=?",
          whereArgs: [sankashaData.sankashaID]);

      if(sankashaMaps.isEmpty){
        await db.insert(
          'sankasha_data',
          sankashaData.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }else{
        await db.update(
          'sankasha_data',
          sankashaData.toMap(),
          where: "sankashaID = ?",
          whereArgs: [sankashaData.sankashaID],
          conflictAlgorithm: ConflictAlgorithm.fail,
        );
      }
    }
  }

  Future<void> deleteGyoshaData(GyoshaDataObj gyoshaDataObj) async {
    String gyoshaID = gyoshaDataObj.gyoshaID;
    final db = await gyoshaDatabase;

    await db.delete(
      'gyosha_data',
      where: "gyoshaID = ?",
      whereArgs: [gyoshaID],
    );

    for (SankashaData sankashaData in gyoshaDataObj.sankashaList) {
      await db.delete(
        'sankasha_data',
        where: 'sankashaID = ?',
        whereArgs: [sankashaData.sankashaID],
      );
    }

    for (TachiDataObj tachiDataObj in gyoshaDataObj.tachiList) {
      var val = await db.delete(
        'tachi_data',
        where: 'tachiID = ?',
        whereArgs: [tachiDataObj.tachiID],
      );
      print("deleted $val");

      for (ShaData shaData in tachiDataObj.shaList) {
        await db.delete(
          'sharesult_data',
          where: 'shaID = ?',
          whereArgs: [shaData.shaID],
        );
      }
    }

  }
}

class DataDBNotifier extends StateNotifier<RecordDB> {
  DataDBNotifier(String dbPath): super(RecordDB(
      dbPath:dbPath,),
  );

}