import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyodoapp/data/data_sankasha_entity.dart';
import 'package:kyodoapp/data/data_sha_entity.dart';
import 'package:kyodoapp/data/data_tachi_object.dart';
import 'data_gyosha_object.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'data_define.dart';
import 'db_define.dart';


class LocalRecordDB extends RecordDB{
  final String dbPath;

  LocalRecordDB({this.dbPath = "data_db.db"}){
    //deleteDatabase(dbPath);
  }

  Future<Database> get gyoshaDatabase async {
    // openDatabase() データベースに接続
    final Future<Database> _database = openDatabase(
      // getDatabasesPath() データベースファイルを保存するパス取得
      join(await getDatabasesPath(), dbPath),
      onCreate: (db, version) {
        _executeCreateGyoshaDB(db);
        _executeCreateSankashaDB(db);
        _executeCreateTachiDB(db);
        _executeCreateShaDB(db);
      },
      version: 1,
    );
    return _database;
  }

  void _executeCreateGyoshaDB(Database db){
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
  }
  void _executeCreateSankashaDB(Database db){
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
  }
  void _executeCreateTachiDB(Database db){
    db.execute(
      // テーブルの作成
        "CREATE TABLE tachi_data(id INTEGER PRIMARY KEY AUTOINCREMENT,"+
            "tachiID TEXT,"+
            "tachiNumber INTEGER,"+
            "gyoshaID TEXT,"+
            "sankashaID TEXT"
                ");"
    );
  }
  void _executeCreateShaDB(Database db){
    db.execute(
      // テーブルの作成
        "CREATE TABLE sha_data(id INTEGER PRIMARY KEY AUTOINCREMENT,"+
            "shaID TEXT,"+
            "shaNumber INTEGER,"+
            "shaResult INTEGER,"+
            "tachiID TEXT"
                ")"
    );
  }

  @override
  Future<int> insertData(String tableName ,DataAbstClass data,{dynamic db}) async {
    print("now");
    db = db??await gyoshaDatabase;
    db = db as Database;
    print(tableName);
    print(data.toMap());
    int id = await db.insert(
      tableName,
      data.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return id;
  }

  @override
  Future<void> updateData(String tableName ,String idName ,dynamic id, DataAbstClass data,{dynamic db}) async{
    print("update");
    print(idName);
    print(id);
    db = db??await gyoshaDatabase;
    db = db as Database;
    var ret = await db.update(
      tableName,
      data.toMap(),
      where: "$idName = ?",
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.fail,
    );

    print(ret);
  }

  @override
  Future<List<Map<String, dynamic>>> queryDataMaps(
      String tableName ,String idName ,String id, {dynamic db}
      ) async{
    db = db??await gyoshaDatabase;
    db = db as Database;
    return await db.query(
        tableName,
        where: "$idName=?",
        whereArgs: [id]
    );
  }

  @override
  Future<void> deleteData(String tableName ,String idName ,String id, {dynamic db}) async {
    print("delete");
    db = db??await gyoshaDatabase;
    db = db as Database;
    var ret = await db.delete(
      tableName,
      where: "$idName = ?",
      whereArgs: [id],
    );
    print(idName+id);
    print(ret);
  }

  @override
  Future<void> insertGyoshaDataObj(GyoshaDataObj gyoshaDataObj) async {
    final db = await gyoshaDatabase;
    await insertData('gyosha_data', gyoshaDataObj.gyoshaData, db: db);

    for(TachiDataObj tachiDataObj in gyoshaDataObj.tachiList){
      await insertData('tachi_data', tachiDataObj.tachiData, db: db);

      for(ShaData shaData in tachiDataObj.shaList){
        await insertData('sha_data', shaData, db: db);
      }
    }
    for(SankashaData sankashaData in gyoshaDataObj.sankashaList){
      await insertData('sankasha_data', sankashaData,db: db);
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

  TachiDataObj getTachiDataObjFromMap(Map<String, dynamic> tachiMap, SankashaData sankashaData){
    return TachiDataObj(
        tachiMap['tachiID'],
        tachiMap['gyoshaID'],
        sankashaData,
        tachiNumber: tachiMap['tachiNumber']);
  }

  SankashaData getSankashaDataFromMap(Map<String, dynamic> sankashaMap){
    return SankashaData(
        sankashaMap['sankashaID'],
        sankashaMap['gyoshaID'],
        sankashaMap['isAppUser'] == 1 ? true : false,
        sankashaName: sankashaMap['sankashaName'],
        sankashaNumber: sankashaMap['sankashaNumber']
    );
  }

  ShaData getShaDataFromMap(Map<String, dynamic> shaMap){
    return ShaData(
        shaMap['shaID'],
        shaMap['shaNumber'],
        ShaResultType.values[shaMap['shaResult']],
        shaMap['tachiID']
    );
  }

  @override
  Future<List<GyoshaDataObj>> getGyoshaDataObjList() async {
    final db = await gyoshaDatabase;
    final List<Map<String, dynamic>> maps = await db.query('gyosha_data');
    final List<GyoshaDataObj> newList = [];

    for(var map in maps){
    var gyoshaDataObj = getGyoshaDataObjFromMap(map);
    newList.add(gyoshaDataObj);
      final List<Map<String, dynamic>> sankashaMaps =
      await queryDataMaps('sankasha_data', 'gyoshaID', map['gyoshaID'],db: db);

      for (var sankashaMap in sankashaMaps) {
        SankashaData sankashaData = getSankashaDataFromMap(sankashaMap);
        gyoshaDataObj.sankashaList.add(sankashaData);
      }

      final List<Map<String, dynamic>> tachiMaps =
      await queryDataMaps("tachi_data",'gyoshaID', map['gyoshaID'],db: db);

      for (var tachiMap in tachiMaps) {
        print(tachiMap);
        String sankashaID = tachiMap['sankashaID'];
        SankashaData sankashaData = gyoshaDataObj.sankashaList.firstWhere(
                (element) => element.sankashaID == sankashaID
        );

        TachiDataObj tachiDataObj = getTachiDataObjFromMap(tachiMap, sankashaData);
        gyoshaDataObj.tachiList.add(tachiDataObj);

        final List<Map<String, dynamic>> shaMaps =
        await queryDataMaps('sha_data', 'tachiID', tachiMap['tachiID'],db: db);
          for (var shaMap in shaMaps) {
            ShaData shaData = getShaDataFromMap(shaMap);
            tachiDataObj.shaList.add(shaData);
          }
      }
    }
    return newList;
  }

  //再起動するたびにインスタンスカウントがリセットされている問題がある
  @override
  Future<void> updateGyoshaData(GyoshaDataObj gyoshaDataObj) async {
    // Get a reference to the database.
    final db = await gyoshaDatabase;

    await updateData('gyosha_data', 'gyoshaID', gyoshaDataObj.gyoshaID, gyoshaDataObj.gyoshaData,db: db);

    for(TachiDataObj tachiDataObj in gyoshaDataObj.tachiList) {
      final List<Map<String, dynamic>> tachiMaps =
      await queryDataMaps('tachi_data', 'tachiID', tachiDataObj.tachiID,db: db);

      if(tachiMaps.isEmpty){
        await insertData('tachi_data', tachiDataObj.tachiData ,db: db);
      }else{
        await updateData('tachi_data', 'tachiID', tachiDataObj.tachiID, tachiDataObj.tachiData,db: db);
      }

      for(ShaData shaData in tachiDataObj.shaList){
        final List<Map<String, dynamic>> shaMaps =
        await queryDataMaps('sha_data', 'shaID', shaData.shaID, db: db);

        if(shaMaps.isEmpty){
          await insertData('sha_data', shaData, db: db);
        }else{
          await updateData('sha_data', 'shaID', shaData.shaID, shaData, db: db);
        }
      }
    }
    for(SankashaData sankashaData in gyoshaDataObj.sankashaList){
      final List<Map<String, dynamic>> sankashaMaps =
      await queryDataMaps('sankasha_data', 'sankashaID', sankashaData.sankashaID, db: db);

      if(sankashaMaps.isEmpty){
        await insertData('sankasha_data', sankashaData, db: db);
      }else{
        await updateData('sankasha_data', 'sankashaID', sankashaData.sankashaID, sankashaData, db: db);
      }
    }
  }

  @override
  Future<void> deleteGyoshaData(GyoshaDataObj gyoshaDataObj) async {
    final db = await gyoshaDatabase;
    await deleteData('gyosha_data', 'gyoshaID', gyoshaDataObj.gyoshaID, db: db);

    for (SankashaData sankashaData in gyoshaDataObj.sankashaList) {
      await deleteData('sankasha_data', 'sankashaID', sankashaData.sankashaID, db: db);
    }

    for (TachiDataObj tachiDataObj in gyoshaDataObj.tachiList) {
      await deleteData('tachi_data', 'tachiID', tachiDataObj.tachiID);

      for (ShaData shaData in tachiDataObj.shaList) {
        await deleteData('sha_data', 'shaID', shaData.shaID, db: db);
      }
    }
  }
}

class DataDBNotifier extends StateNotifier<LocalRecordDB> {
  DataDBNotifier(String dbPath): super(LocalRecordDB(
      dbPath:dbPath,),
  );
}