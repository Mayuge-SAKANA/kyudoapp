import 'data_define.dart';
import 'data_gyosha_entity.dart';
import 'data_sankasha_entity.dart';
import 'data_tachi_object.dart';
import 'db_define.dart';

class GyoshaDataObj {
  static int _gyoshaInstanceNumber = 0;
  int _sankashaInstanceNumber = 0;
  int _tachiInstanceNumber = 0;
  bool isLocked = false;

  final GyoshaData gyoshaData;
  List<TachiDataObj> tachiList = []; //立集合
  List<SankashaData> sankashaList = [];//参加者リスト
  bool isAppUserIsSankasha = true;

  SankashaData? get appUserData=>getAppUserData();
  String get appUserID =>appUserData==null? "":appUserData!.sankashaID;
  String get gyoshaID=> gyoshaData.gyoshaID;
  int get totalTekichu =>countUserAtariTotal(appUserID);
  int get totalSha =>countUserShaTotal(appUserID);
  int get sankashaNum =>sankashaList.length;

  int get renshuHour => calcGyoshaTime().inHours;
  int get renshuMinutes => calcGyoshaTime().inMinutes - renshuHour*60;

  ShakaiResultDataObj get shakaiResultDataObj => ShakaiResultDataObj(this);


  GyoshaDataObj(mainEditorName, gyoshaName, gyoshaType, startDateTime,finishDateTime,
  {memoText = '',gyoshaState = GyoshaState.offline,
    int startCountNumber = -1,gyoshaID = "",bool newFlag = true,RecordDB? recordDB, gyoshaEnKin = GyoshaEnKin.kinteki}):
      gyoshaData = GyoshaData(gyoshaID == "" ?generateID('TEST',_gyoshaInstanceNumber+1):gyoshaID,mainEditorName, gyoshaName,
          startDateTime, finishDateTime,gyoshaType: gyoshaType,gyoshaState: gyoshaState,memoText: memoText,gyoshaEnKin: gyoshaEnKin)
  {

   // if(newFlag){
   //   addSankasha(mainEditorName,isAppUser:true,recordDB: recordDB);
    // }

    if(startCountNumber>-1) _gyoshaInstanceNumber = startCountNumber;
    _gyoshaInstanceNumber++;
  }

  Future<SankashaData> addSankasha(String newSankashaName,{bool isAppUser=false,RecordDB? recordDB})async{
    _sankashaInstanceNumber++;
    String newSankashaID = generateID('TEST', _sankashaInstanceNumber);
    var newSankasha = SankashaData(newSankashaID, gyoshaID, isAppUser, sankashaName: newSankashaName, sankashaNumber: sankashaList.length);
    sankashaList.add(newSankasha);

    if(recordDB!=null){
      var dbId = await recordDB.insertData('sankasha_data', newSankasha);
      String newSankashaID = generateID('U', dbId);
      newSankasha.sankashaID = newSankashaID;
      await recordDB.updateData('sankasha_data', 'id', dbId, newSankasha);
      sankashaList.last.sankashaID = newSankashaID;

    }
    return newSankasha;
  }

  void removeSankashaAt(String sankashaID,{RecordDB? recordDB}){

    if(appUserID == sankashaID){
      isAppUserIsSankasha=false;
    }

    sankashaList = [...sankashaList.where((item){return item.sankashaID!=sankashaID;})];
    tachiList = [...tachiList.where((item)=>item.sankashaData.sankashaID!=sankashaID)];
    if(recordDB!=null){
      recordDB.deleteData('sankasha_data', 'sankashaID', sankashaID);
      recordDB.deleteData('tachi_data', 'sankashaID', sankashaID);
    }

    setTachiIndex(recordDB:recordDB);
    setSankashaIndex(recordDB:recordDB);

  }

  SankashaData getSankashaAt(String sankashaID){
    return sankashaList.firstWhere((element){
      return element.sankashaID==sankashaID;
    });
  }
  SankashaData? getAppUserData(){
    try {
      return sankashaList.firstWhere((element) =>
      element.isAppUser == true);
    }catch(e){
      return null;
    }
  }
  void deleteAppUserData({RecordDB? recordDB})async{
    String deleteID = appUserID;

    tachiList = [...tachiList.where((item)=>item.sankashaData.sankashaID!=deleteID)];
    sankashaList = [...sankashaList.where((item) => item.sankashaID!=deleteID) ];

    isAppUserIsSankasha = false;
    if(recordDB!=null){
      await recordDB.deleteData('sankasha_data', 'sankashaID', deleteID);
      await recordDB.deleteData('tachi_data', 'sankashaID', deleteID);
    }
    setTachiIndex(recordDB: recordDB);
    setSankashaIndex(recordDB: recordDB);
  }


  void addAppUserToSankasha({RecordDB? recordDB})async{
    if(isAppUserIsSankasha==false) {
      await addSankasha("ユーザ",isAppUser: true);
    }

    isAppUserIsSankasha = true;
    setSankashaIndex(recordDB: recordDB);
  }
  Future<void> setSankashaIndex({RecordDB? recordDB})async{
    sankashaList = List.generate(sankashaList.length, (index) {
      SankashaData sankashaData = sankashaList[index];
      sankashaData.sankashaNumber = index;
      if(recordDB!=null){
        recordDB.updateData('sankasha_data', 'sankashaID', sankashaData.sankashaID, sankashaData);
      }
      return sankashaData;
    });
  }

  Future<void> setTachiIndex({RecordDB? recordDB})async{
    tachiList = List.generate(tachiList.length, (index){
      TachiDataObj tachiDataObj = tachiList[index];
      tachiDataObj.tachiData.tachiNumber = index;
      if(recordDB!=null){
        recordDB.updateData('tachi_data', 'tachiID', tachiDataObj.tachiID, tachiDataObj.tachiData);
      }
      return tachiDataObj;
    }).toList();
  }

  //編集画面でaddした時のロジックをこっちに持ってくる必要がある

  Future<void> addTachi({bool addAll = true,RecordDB? recordDB})async{


    if(addAll==true){
      bool deleteStopFlag = false;
      for(int i = tachiList.length-1; i>-1; i--){
        if(deleteStopFlag==true)break;
        if(tachiList[i].shaList.isEmpty){
          await removeTachiAt(tachiList[i].tachiID,recordDB:recordDB);
        }else{
          deleteStopFlag=true;
        }
      }

      for(SankashaData sankashaData in sankashaList){

        _tachiInstanceNumber++;

        String tachiID = generateID('TEST', _tachiInstanceNumber);
        var tachiDataObj = TachiDataObj(tachiID, gyoshaID,sankashaData, tachiNumber: tachiList.length-1);
        tachiList.add(tachiDataObj);

        if(recordDB!=null){

          var dbId = await recordDB.insertData('tachi_data', tachiDataObj.tachiData);
          String newTachiID = generateID('T', dbId);
          tachiDataObj.tachiData.tachiID = newTachiID;
          //tachiList.last.tachiData.tachiID = newTachiID;
          await recordDB.updateData('tachi_data', 'id', dbId, tachiDataObj.tachiData);

        }

      }
    }
  }
  Future<void> removeTachiAt(String tachiID,{RecordDB? recordDB})async{
    tachiList = tachiList.where((item)=>item.tachiID!=tachiID).toList();
    if(recordDB!=null){
      await recordDB.deleteData('tachi_data', 'tachiID', tachiID);
    }
    await setTachiIndex();
  }

  int countUserAtariTotal(String sankashaID){
    return tachiList.where((element) => element.sankashaData.sankashaID==sankashaID).fold(0, (previousValue, element)=>previousValue+element.atariShaNum);
  }
  int countUserShaTotal(String sankashaID){
    return tachiList.where((element) => element.sankashaData.sankashaID==sankashaID).fold(0, (previousValue, element) => previousValue+element.totalShaNum);
  }
  List<TachiDataObj> collectUserTachiData(String sankashaID){
    return tachiList.where((element) => element.sankashaData.sankashaID==sankashaID).toList();
   }

  Duration calcGyoshaTime(){
    Duration diff = gyoshaData.finishDateTime.difference(gyoshaData.startDateTime);
    return diff;
  }
}