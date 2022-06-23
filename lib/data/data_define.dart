import 'data_tachi_object.dart';
import 'data_gyosha_object.dart';
import 'data_sankasha_entity.dart';

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

Map<ShaResultType, String> shaResultString = {
  ShaResultType.atari: "○",
  ShaResultType.hazure: "✕",
  ShaResultType.shitsu: "失",
  ShaResultType.fumei: "？",
  ShaResultType.nashi: "－",
  ShaResultType.delete: "",
};

class ShakaiResultDataObj{
  final GyoshaDataObj gyoshaDataObj;
  Map<String,SankashaResultDataObj> sankashaResultMap= {};
  final Map<String, double>scoreMap = {};
  List<MapEntry>orderedScoreList = [];
  final Map<String, int>rankingMap = {};

  ShakaiResultDataObj(this.gyoshaDataObj){
    sankashaResultMap = Map.fromIterables(
        gyoshaDataObj.sankashaList.map((e) => e.sankashaID),
        gyoshaDataObj.sankashaList.map((e) => SankashaResultDataObj(gyoshaDataObj, e))
    );
    _createOrderedScoreList();
    _setRankingIndex();
  }

  void _createOrderedScoreList(){
    List<MapEntry> _orderData(Map<String, dynamic>maps,
        int Function(MapEntry<String, dynamic>,
            MapEntry<String, dynamic>) sorter){
      return maps.entries.toList()..sort((a, b)=> sorter(a, b));
    }
    orderedScoreList =_orderData(sankashaResultMap,
            (a, b) => (b.value as SankashaResultDataObj).tekichuRate.compareTo((a.value as SankashaResultDataObj).tekichuRate));
  }
  void _setRankingIndex(){
    int rankCounter = 1;
    double oldScore = -100;
    for(int i = 0;i<orderedScoreList.length;i++){
      double newScore = orderedScoreList[i].value.tekichuRate;
      if(oldScore-newScore>0.001){rankCounter++;}
      oldScore=newScore;
      rankingMap[orderedScoreList[i].key] = rankCounter;
    }
  }

  String generateResultString(String appUserName){
    String result = "";
    result += gyoshaDataObj.gyoshaData.gyoshaName+"\n";


    for(var sankashaData in gyoshaDataObj.sankashaList){
      var sankashaID = sankashaData.sankashaID;
      result += sankashaData.isAppUser==true? appUserName.padRight(5,"　"):sankashaData.sankashaName.padRight(5,"　");
      if(sankashaResultMap.containsKey(sankashaID)==false){
        continue;
      }
      SankashaResultDataObj data = sankashaResultMap[sankashaID]!;
      result+= data.totalSha>0?(data.atariSha).toString()+"本/"+(data.totalSha).toString()+"本":"-本/-本";
      result+= "(";
      result+= data.totalSha>0?(100*data.atariSha/data.totalSha).toStringAsFixed(1):"-";
      result+= "%)\n";
      for(var item in data.resultList){
        result += shaResultString[item]!;
      }
      result+="\n";
    }
    if(gyoshaDataObj.gyoshaData.memoText!=null){
      result += "*--*\n";
      result += gyoshaDataObj.gyoshaData.memoText==null?"":gyoshaDataObj.gyoshaData.memoText!+"\n";
    }



    return result;
  }

}

class SankashaResultDataObj{
  final GyoshaDataObj gyoshaDataObj;
  final SankashaData sankashaData;
  List<ShaResultType> resultList = [];
  int get totalSha =>gyoshaDataObj.countUserShaTotal(sankashaData.sankashaID);
  int get atariSha =>gyoshaDataObj.countUserAtariTotal(sankashaData.sankashaID);
  double get tekichuRate =>_calcTekichuRate();

  SankashaResultDataObj(this.gyoshaDataObj, this.sankashaData){
      List<TachiDataObj> userTachiList = gyoshaDataObj.collectUserTachiData(
          sankashaData.sankashaID);
      for (TachiDataObj tachiData in userTachiList) {
        resultList = [...resultList,...tachiData.shaList.map((e) => e.shaResult)];
      }
    }
  double _calcTekichuRate(){
     return totalSha != 0 ? (atariSha / totalSha) : 0.0;
  }
}


abstract class DataAbstClass{
  Map<String, dynamic> toMap();
}

