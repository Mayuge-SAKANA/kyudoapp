import 'data_define.dart';
import 'data_tachi_define.dart';

class GyoshaData extends DataAbstClass {
  static int _gyoshaInstanceNumber = 0;
  final String gyoshaID; //行射固有ID
  final String mainEditorName; // 編集者名
  final GyoshaState gyoshaState; //オンラインオフライン
  String gyoshaName; //行射タイトル
  GyoshaType gyoshaType; //行射種類
  DateTime startDateTime;//開始時間
  DateTime finishDateTime; //終了時間
  String memoText; //メモ内容
  bool isAppUserIsSankasha = true;
  String appUserID = "";
  SankashaData? appUserData;

  int _tachiInstanceNumber = 0;
  int _sankashaInstanceNumber = 0;
  final List<TachiData> tachiList = []; //立集合
  final List<SankashaData> sankashaList = [];//参加者リスト

  String get startDateTimeStr =>dateTimeToString(startDateTime); //開始時間
  String get finishDateTimeStr => dateTimeToString(finishDateTime); //終了時間
  int get renshuHour => calcGyoshaTime().inHours;
  int get renshuMinutes => calcGyoshaTime().inMinutes - renshuHour*60;
  int get totalTekichu =>countUserAtariTotal(appUserID);
  int get totalSha =>countUserShaTotal(appUserID);


  int get sankashaNum =>sankashaList.length;

  GyoshaData(this.mainEditorName, this.gyoshaName,
      this.gyoshaType, this.startDateTime,this.finishDateTime,
      {this.memoText = '',this.gyoshaState = GyoshaState.offline, bool initInstanceNum = false, int startInstanceNum = 0}):
        gyoshaID=generateID('G',_gyoshaInstanceNumber+1)
  {
    appUserData = addSankasha(mainEditorName,isAppUser:true);
    appUserID = appUserData!.sankashaID;
    _gyoshaInstanceNumber++;
    if(initInstanceNum==true){
      _gyoshaInstanceNumber = startInstanceNum;
    }

  }

  SankashaData addSankasha(String newSankashaName,{bool isAppUser=false}){
    _sankashaInstanceNumber++;
    String newSankashaID = gyoshaID+generateID('U', _sankashaInstanceNumber);
    String newSankashaViewName = newSankashaName.substring(0,newSankashaName.length<2? newSankashaName.length:2);
    var newSankasha = SankashaData(newSankashaID, gyoshaID, isAppUser,
        sankashaName: newSankashaName,sankashaViewName: newSankashaViewName);
    sankashaList.add(newSankasha);
    return newSankasha;
  }
  void removeSankashaAt(index){
    if(sankashaList[index].isAppUser==true){
      isAppUserIsSankasha=false;
    }
    sankashaList.removeAt(index);
  }

  void deleteAppUserData(){
    for(int i=tachiList.length-1;i>-1;i--){
      if(tachiList[i].sankashaData!=null &&tachiList[i].sankashaData!.sankashaID ==appUserID){
        tachiList.removeAt(i);
      }
    }
    for(int i=0;i<sankashaList.length;i++){
      if(sankashaList[i].sankashaID==appUserID){
        sankashaList.removeAt(i);
        break;
      }
    }
    isAppUserIsSankasha = false;
  }
  void addAppUserToSankasha(){
    if(isAppUserIsSankasha==false) {
      sankashaList.insert(0,appUserData!);
    }
    isAppUserIsSankasha = true;
  }
  void addTachi({int tachiJun = 1 ,bool addAll = true}){
    if(addAll==true){
      for(SankashaData sankashaData in sankashaList){
        _tachiInstanceNumber++;
        String tachiID = gyoshaID+generateID('T', _tachiInstanceNumber);
        var tachiData = TachiData(tachiID, gyoshaID,sankashaData:sankashaData, tachiJun: tachiJun,  tachiNumber: _tachiInstanceNumber);
        tachiList.add(tachiData);
      }
    }else {
      _tachiInstanceNumber++;
      String tachiID = gyoshaID+generateID('T', _tachiInstanceNumber);
      var tachiData = TachiData(tachiID, gyoshaID, tachiJun: tachiJun,
          tachiNumber: _tachiInstanceNumber);
      tachiList.add(tachiData);
    }
  }
  void removeTachiAt(int index){
    tachiList.removeAt(index);
  }
  int countAtariTotal(){
    int atariTotal = 0;
    for(TachiData tachiData in tachiList){
      atariTotal += tachiData.atariShaNum;
    }
    return atariTotal;
  }
  int countShaTotal(){
    int shaTotal = 0;
    for(TachiData tachiData in tachiList){
      shaTotal += tachiData.totalShaNum;
    }
    return shaTotal;
  }
  int countUserAtariTotal(String sankashaID){
    int atariTotal = 0;
    if(sankashaID==""){
      return 0;
    }

    for(TachiData tachiData in tachiList){
      if(tachiData.sankashaData!=null && tachiData.sankashaData!.sankashaID==sankashaID) {
        atariTotal += tachiData.atariShaNum;
      }
    }
    return atariTotal;
  }
  int countUserShaTotal(String sankashaID){
    int shaTotal = 0;
    if(sankashaID==""){
      return 0;
    }
    for(TachiData tachiData in tachiList){
      if(tachiData.sankashaData!=null && tachiData.sankashaData!.sankashaID==sankashaID) {
        shaTotal += tachiData.totalShaNum;
      }
    }
    return shaTotal;
  }
  List<TachiData> collectUserTachiData(String sankashaID){
    List<TachiData> userTachi = [];
    for(TachiData tachiData in tachiList) {
      if (tachiData.sankashaData != null && tachiData.sankashaData!.sankashaID == sankashaID) {
        userTachi.add(tachiData);
      }
    }
    return userTachi;
  }
  Duration calcGyoshaTime(){
    Duration diff = finishDateTime.difference(startDateTime);
    return diff;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'savedInstanceNum':_gyoshaInstanceNumber,
      'gyoshaID': gyoshaID, //行射固有ID
      'mainEditorName': mainEditorName, // 編集者名
      'gyoshaState':gyoshaState.index, //オンラインオフライン
      'gyoshaName': gyoshaName,//行射タイトル
      'gyoshaType': gyoshaType.index, //行射種類
      'startYear':startDateTime.year,//開始時間
      'startMonth':startDateTime.month,//開始時間
      'startDay':startDateTime.day,//開始時間
      'startHour':startDateTime.hour,//開始時間
      'startMinute':startDateTime.minute,//開始時間
      'finishYear':finishDateTime.year,//終了時間
      'finishMonth':finishDateTime.month,//終了時間
      'finishDay':finishDateTime.day,//終了時間
      'finishHour':finishDateTime.hour,//終了時間
      'finishMinute':finishDateTime.minute,//終了時間
      'memoText':memoText,//メモ内容
      'isAppUserIsSankasha':isAppUserIsSankasha,//ユーザーが射に参加しているかどうか
      'appUserID': appUserID,
      'tachiInstanceNumber' : _tachiInstanceNumber,
      'sankashaInstanceNumber' : _sankashaInstanceNumber,
    };
  }
}

