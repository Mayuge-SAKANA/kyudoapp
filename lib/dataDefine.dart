
String generateID(String fstCap, int index, {int zeronum = 4}){
  return fstCap+index.toString().padLeft(zeronum,'0');
}

String listToString(List<String> list) {
  return list.map<String>((String value) => value.toString()).join(',');
}

String dateTimeToString(DateTime dt){
  String datetime =
      dt.year.toString()+dt.month.toString().padLeft(2,"0")+dt.day.toString().padLeft(2,"0")+
          dt.hour.toString().padLeft(2,"0")+dt.minute.toString().padLeft(2,"0")+dt.second.toString().padLeft(2,"0");
  return datetime;
}

DateTime stringToDateTime(String datetime){
  DateTime copyDay = DateTime(int.parse(datetime.substring(0,4)), int.parse(datetime.substring(4,6)),int.parse(datetime.substring(6,8)),
      int.parse(datetime.substring(8,10)),int.parse(datetime.substring(10,12)),int.parse(datetime.substring(12,14)));
  return copyDay;
}

enum GyoshaState{
  online,
  offline,
}

enum GyoshaType{
  renshu, //練習
  shakai, //射会
  shiai, //試合
}

enum ShaResultType{
  atari, //当たり
  hazure, //はずれ
  shitsu, //失
  fumei, //不明
  nashi, //なし
  delete,
}

class ShakaiResultDataObj{
  final GyoshaData gyoshaData;
  final Map<String,SankashaResultDataObj> sankashaResultMap= {};
  final Map<String, double>scoreMap = {};
  List<MapEntry>orderedScoreList = [];
  final Map<String, int>rankingMap = {};

  ShakaiResultDataObj(this.gyoshaData){
    for(SankashaData sankashaData in gyoshaData.sankashaList){
      sankashaResultMap[sankashaData.sankashaID]=SankashaResultDataObj(gyoshaData, sankashaData);

      List<MapEntry> _orderData(Map<String, dynamic>maps, int
      Function(MapEntry<String, dynamic>, MapEntry<String, dynamic>) sorter){
        return maps.entries.toList()..sort((a, b)=> sorter(a, b));
      }
      orderedScoreList =_orderData(sankashaResultMap, (a, b) => (b.value as
      SankashaResultDataObj).tekichuRate.compareTo((a.value as SankashaResultDataObj).tekichuRate));
      int rankCounter = 1;
      double oldScore = -100;
      for(int i = 0;i<orderedScoreList.length;i++){
        double newScore = orderedScoreList[i].value.tekichuRate;
        if(oldScore-newScore>0.001){
          rankCounter++;
        }
        oldScore=newScore;
        rankingMap[orderedScoreList[i].key] = rankCounter;
      }
    }
  }


}

class SankashaResultDataObj{
  final GyoshaData gyoshaData;
  final SankashaData sankashaData;
  final List<ShaResultType> resultList = [];
  int get totalSha =>gyoshaData.countUserShaTotal(sankashaData.sankashaID);
  int get atariSha =>gyoshaData.countUserAtariTotal(sankashaData.sankashaID);
  double get tekichuRate =>_calcTekichuRate();

  SankashaResultDataObj(this.gyoshaData, this.sankashaData){
      List<TachiData> userTachiList = gyoshaData.collectUserTachiData(
          sankashaData.sankashaID);
      for (TachiData tachiData in userTachiList) {
        for (ShaData shaData in tachiData.shaList) {
          resultList.add(shaData.shaResult);
        }
      }
      int totalSha = gyoshaData.countUserShaTotal(sankashaData.sankashaID);
      int atariSha = gyoshaData.countUserAtariTotal(sankashaData.sankashaID);
      double tekichuRate = totalSha != 0 ? (atariSha / totalSha) : 0;
    }
  double _calcTekichuRate(){
     return totalSha != 0 ? (atariSha / totalSha) : 0.0;
  }

}



abstract class DataAbstClass{
  Map<String, dynamic> toMap();
}

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

  String get startDateTimeStr =>dateTimeToString(startDateTime); //開始時間
  String get finishDateTimeStr => dateTimeToString(finishDateTime); //終了時間
  int get renshuHour => calcGyoshaTime().inHours;
  int get renshuMinutes => calcGyoshaTime().inMinutes - renshuHour*60;
  int get totalTekichu =>countUserAtariTotal(appUserID);
  int get totalSha =>countUserShaTotal(appUserID);

  final List<String> _editorList = []; //編集者リスト
  final List<TachiData> tachiList = []; //立集合
  final List<SankashaData> sankashaList = [];//参加者リスト

  int get sankashaNum =>sankashaList.length;
  List<String> sankashaNames = [];
  Map<String,String> sankashaNamesMap={};
  Map<String,String> sankashaIDMap={};

  GyoshaData(this.mainEditorName, this.gyoshaName,
      this.gyoshaType, this.startDateTime,this.finishDateTime,
      {this.memoText = '',this.gyoshaState = GyoshaState.offline, }):
      gyoshaID=generateID('G',_gyoshaInstanceNumber+1)
    {
      appUserData = addSankasha(mainEditorName,isAppUser:true);
      appUserID = appUserData!.sankashaID;
      _gyoshaInstanceNumber++;
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
        String itename = sankashaData.sankashaName;
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
      'gyoshaID': gyoshaID, //行射固有ID
      'mainEditorName': mainEditorName, // 編集者名
      'gyoshaName': gyoshaName, //行射タイトル
      'gyoshaType': gyoshaType.index, //行射種類
      'startDateTime': startDateTime, //開始時間
      'finishDateTime': finishDateTime, //終了時間
      'memoText': memoText, //メモ内容
    };
  }
}

class TachiData extends DataAbstClass {
  final String tachiID; //立固有ID

  int? tachiJun; //立ち順(大前など)
  int tachiNumber; //練習中何番目の立ちか
  final String gyoshaID; //行射固有ID
  final List<ShaData> shaList = []; //射集合
  SankashaData? sankashaData;

  String get iteName=> sankashaData?.sankashaName??"";
   //射手名

  int get totalShaNum => shaList.length;
  int get atariShaNum => countAtariSha();
  int _shaInstanceNumber = 0;

  TachiData(this.tachiID,  this.gyoshaID,{this.sankashaData,this.tachiJun = 0,this.tachiNumber = 0});

  void createSha(ShaResultType shaResult){
    _shaInstanceNumber++;
    String shaID = tachiID+generateID('S', _shaInstanceNumber);
    var shaData = ShaData(shaID,shaList.length+1,shaResult,tachiID);
    shaList.add(shaData);
  }

  int countAtariSha(){
    int atariCount = 0;
    for (var shaData in shaList) {
      if(shaData.shaResult==ShaResultType.atari){atariCount++;}
    }
    return atariCount;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'tachiID': tachiID, //立固有ID
      'iteName': iteName, //射手名
      'tachiNumber' : tachiNumber,//立ち順(大前など)
      'tachiJun' : tachiJun,//立ち順(大前など)
      'gyoshaID': gyoshaID,//行射固有ID
    };
  }
}

class ShaData extends DataAbstClass{
  final String shaID; //射固有ID
  final int shaNumber; //矢が何本目か
  ShaResultType shaResult; //的中結果
  final String tachiID; //立固有ID
  ShaData(this.shaID,this.shaNumber,this.shaResult,this.tachiID);

  @override
  Map<String, dynamic> toMap() {
    return {
      'shaID': shaID, //射固有ID
      'shaNumber': shaNumber, //矢が何本目か
      'shaResult' : shaResult.index,//的中結果
      'tachiID': tachiID,//立固有ID
    };
  }
}

class SankashaData extends DataAbstClass{
  final String sankashaID;
  final String gyoshaID;
  String sankashaName;
  String sankashaViewName;
  bool isAppUser;

  SankashaData(this.sankashaID,this.gyoshaID,this.isAppUser,{this.sankashaName = "",this.sankashaViewName = ""});

  @override
  Map<String, dynamic> toMap() {
    return {
      'sankashaID':sankashaID,
      'gyoshaID':gyoshaID,
      'isAppUser':isAppUser,
      'sankashaName':sankashaName,
      'sankashaViewName':sankashaViewName,
    };
    }
}