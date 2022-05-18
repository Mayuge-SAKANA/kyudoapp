import 'data_define.dart';
import 'data_sha_define.dart';

class TachiData extends DataAbstClass {
  final String tachiID; //立固有ID
  int? tachiJun; //立ち順(大前など)
  int tachiNumber; //練習中何番目の立ちか
  final String gyoshaID; //行射固有ID
  int _shaInstanceNumber = 0;
  final List<ShaData> shaList = []; //射集合
  SankashaData? sankashaData;

  String get iteName=> sankashaData?.sankashaName??"";
  //射手名

  int get totalShaNum => shaList.length;
  int get atariShaNum => countAtariSha();


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
      'tachiJun': tachiJun ?? -1, //立ち順(大前など)
      'tachiNumber': tachiNumber, //練習中何番目の立ちか
      'gyoshaID': gyoshaID, //行射固有ID
      'shaInstanceNumber': _shaInstanceNumber,
    };
  }
}
