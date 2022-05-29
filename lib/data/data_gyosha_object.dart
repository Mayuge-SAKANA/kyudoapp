import 'data_define.dart';
import 'data_gyosha_entity.dart';
import 'data_sankasha_entity.dart';
import 'data_tachi_object.dart';


class GyoshaDataObj {
  static int _gyoshaInstanceNumber = 0;
  int _sankashaInstanceNumber = 0;
  int _tachiInstanceNumber = 0;

  final GyoshaData gyoshaData;
  List<TachiDataObj> tachiList = []; //立集合
  List<SankashaData> sankashaList = [];//参加者リスト
  bool isAppUserIsSankasha = true;
  String appUserID = "";
  SankashaData? appUserData;
  String get gyoshaID=> gyoshaData.gyoshaID;
  int get totalTekichu =>countUserAtariTotal(appUserID);
  int get totalSha =>countUserShaTotal(appUserID);
  int get sankashaNum =>sankashaList.length;

  int get renshuHour => calcGyoshaTime().inHours;
  int get renshuMinutes => calcGyoshaTime().inMinutes - renshuHour*60;

  ShakaiResultDataObj get shakaiResultDataObj => ShakaiResultDataObj(this);

  GyoshaDataObj(mainEditorName, gyoshaName, gyoshaType, startDateTime,finishDateTime,
  {memoText = '',gyoshaState = GyoshaState.offline,int startCountNumber = -1}):
      gyoshaData = GyoshaData(generateID('G',_gyoshaInstanceNumber+1),mainEditorName, gyoshaName, startDateTime, finishDateTime)
  {
    appUserData = addSankasha(mainEditorName,isAppUser:true);
    appUserID = appUserData!.sankashaID;
    if(startCountNumber>-1) _gyoshaInstanceNumber = startCountNumber;
    _gyoshaInstanceNumber++;
  }

  SankashaData addSankasha(String newSankashaName,{bool isAppUser=false}){
    _sankashaInstanceNumber++;
    String newSankashaID = gyoshaID+generateID('U', _sankashaInstanceNumber);
    var newSankasha = SankashaData(newSankashaID, gyoshaID, isAppUser, sankashaName: newSankashaName, sankashaNumber: sankashaList.length-1);
    sankashaList.add(newSankasha);
    return newSankasha;
  }

  void removeSankashaAt(String sankashaID){
    if(appUserID == sankashaID){
      isAppUserIsSankasha=false;
    }
    sankashaList = [...sankashaList.where((item){return item.sankashaID!=sankashaID;})];
    tachiList = [...tachiList.where((item)=>item.sankashaData.sankashaID!=appUserID)];
    setTachiIndex();
    setSankashaIndex();

  }

  void deleteAppUserData(){
    tachiList = [...tachiList.where((item)=>item.sankashaData.sankashaID!=appUserID)];
    sankashaList = [...sankashaList.where((item) => item.sankashaID!=appUserID) ];
    isAppUserIsSankasha = false;
    setTachiIndex();
    setSankashaIndex();
  }

  void addAppUserToSankasha(){
    if(isAppUserIsSankasha==false) {
      sankashaList = [appUserData!,...sankashaList];
    }
    isAppUserIsSankasha = true;
    setSankashaIndex();
  }

  void setSankashaIndex(){
    sankashaList = List.generate(sankashaList.length, (index) {
      SankashaData sankashaData = sankashaList[index];
      sankashaData.sankashaNumber = index;
      return sankashaData;
    });
  }

  void setTachiIndex(){
    tachiList = List.generate(tachiList.length, (index){
      TachiDataObj tachiDataObj = tachiList[index];
      tachiDataObj.tachiData.tachiNumber = index;
      return tachiDataObj;
    }).toList();
  }

  void addTachi({bool addAll = true}){
    if(addAll==true){
      for(SankashaData sankashaData in sankashaList){
        _tachiInstanceNumber++;
        String tachiID = gyoshaID+generateID('T', _tachiInstanceNumber);
        var tachiData = TachiDataObj(tachiID, gyoshaID,sankashaData, tachiNumber: tachiList.length-1);
        tachiList.add(tachiData);
      }
    }
  }
  void removeTachiAt(String tachiID){
    tachiList = tachiList.where((item)=>item.tachiID!=tachiID).toList();
    setTachiIndex();
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