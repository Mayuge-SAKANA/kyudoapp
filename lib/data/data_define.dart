import 'data_sha_define.dart';
import 'data_tachi_define.dart';
import 'data_gyosha_define.dart';

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
    }
  double _calcTekichuRate(){
     return totalSha != 0 ? (atariSha / totalSha) : 0.0;
  }

}



abstract class DataAbstClass{
  Map<String, dynamic> toMap();
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
    'sankashaID': sankashaID,
    'gyoshaID': gyoshaID,
    'sankashaName': sankashaName,
    'sankashaViewName':sankashaViewName,
    'isAppUser': isAppUser,
    };
    }
}