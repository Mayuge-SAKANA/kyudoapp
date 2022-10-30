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
  dantai,//団体戦
}

enum GyoshaEnKin{
 enteki,//遠的
 kinteki,//近的
}

enum ShaResultType{
  atari, //当たり
  hazure, //はずれ
  shitsu, //失
  fumei, //不明
  nashi, //なし
  delete,
  ten, //10
  nine, //9
  seven, //7
  five, //5
  three, //3
  zero, //0
}

Map<ShaResultType, String> shaResultString = {
  ShaResultType.atari: "○",
  ShaResultType.hazure: "✕",
  ShaResultType.shitsu: "失",
  ShaResultType.fumei: "？",
  ShaResultType.nashi: "－",
  ShaResultType.delete: "",
  ShaResultType.ten: "10 ",
  ShaResultType.nine: "9 ",
  ShaResultType.seven: "7 ",
  ShaResultType.five: "5 ",
  ShaResultType.three: "3 ",
  ShaResultType.zero: "0 ",
};

Map<ShaResultType,int> shaResultValue = {
  ShaResultType.atari: 1,
  ShaResultType.hazure: 0,
  ShaResultType.shitsu: 0,
  ShaResultType.fumei: 0,
  ShaResultType.nashi: 0,
  ShaResultType.delete: 0,
  ShaResultType.ten: 10,
  ShaResultType.nine: 9,
  ShaResultType.seven: 7,
  ShaResultType.five: 5,
  ShaResultType.three: 3,
  ShaResultType.zero: 0
};

class ShakaiResultDataObj{
  final GyoshaDataObj gyoshaDataObj;
  Map<String,SankashaResultDataObj> sankashaResultMap= {};
  final Map<String, double>scoreMap = {};
  List<MapEntry>orderedScoreList = [];
  final Map<String, int>rankingMap = {};

  int get totalSha => sankashaResultMap.values.fold(0, (previousValue, element) => previousValue+element.totalSha);
  int get totalAtariSha => sankashaResultMap.values.fold(0, (previousValue, element) => previousValue+element.atariSha);

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
    String dateStr = "${gyoshaDataObj.gyoshaData.startDateTime.year}年${gyoshaDataObj.gyoshaData.startDateTime.month}月${gyoshaDataObj.gyoshaData.startDateTime.day}日";
    result += "${gyoshaDataObj.gyoshaData.gyoshaName}($dateStr)\n";
    result += "*--*\n";


    for(var sankashaData in gyoshaDataObj.sankashaList){
      var sankashaID = sankashaData.sankashaID;
      if(gyoshaDataObj.gyoshaData.gyoshaType==GyoshaType.shiai||gyoshaDataObj.gyoshaData.gyoshaType==GyoshaType.shakai){
        result+="${rankingMap[sankashaID]??0}位 ";
      }
      result += sankashaData.isAppUser==true? appUserName.padRight(5,"　"):sankashaData.sankashaName.padRight(5,"　");
      if(sankashaResultMap.containsKey(sankashaID)==false){
        continue;
      }
      SankashaResultDataObj data = sankashaResultMap[sankashaID]!;

      if(gyoshaDataObj.gyoshaData.gyoshaType!=GyoshaType.dantai){
        if(gyoshaDataObj.gyoshaData.gyoshaEnKin==GyoshaEnKin.kinteki) {
          result +=
          data.totalSha > 0 ? "${data.atariSha}本/${data.totalSha}本" : "-本/-本";
          result += "(";
          result += data.totalSha > 0 ? (100 * data.atariSha / data.totalSha)
              .toStringAsFixed(1) : "-";
          result += "%)\n";
        }else if(gyoshaDataObj.gyoshaData.gyoshaEnKin==GyoshaEnKin.enteki){
          result +=
          data.totalSha > 0 ? "${data.atariSha}点" : "-点";
          result += "\n";
        }
      }

      for(var item in data.resultList){
        result += shaResultString[item]!;
      }
      result+="\n";
    }

    result += "*--*\n";
    if(gyoshaDataObj.gyoshaData.gyoshaType==GyoshaType.dantai){
      String dantaiResult = "合計";
      if(gyoshaDataObj.gyoshaData.gyoshaEnKin==GyoshaEnKin.kinteki) {
        dantaiResult += totalSha == 0 ? "-" : totalAtariSha.toString();
        dantaiResult += "本/";
        dantaiResult += totalSha == 0 ? "-" : totalSha.toString();
        dantaiResult += "本(";
        dantaiResult +=
        totalSha == 0 ? "-" : (100 * totalAtariSha / totalSha).toStringAsFixed(
            1);
        dantaiResult += ")";

      }else if(gyoshaDataObj.gyoshaData.gyoshaEnKin==GyoshaEnKin.enteki){
        dantaiResult += totalSha==0?"-":totalAtariSha.toString();
        dantaiResult += "点";
      }
      result += dantaiResult;
      result += "\n";

    }

    result += gyoshaDataObj.gyoshaData.memoText==null?"":gyoshaDataObj.gyoshaData.memoText!;




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

