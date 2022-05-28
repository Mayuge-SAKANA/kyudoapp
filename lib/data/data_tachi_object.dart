import 'data_define.dart';
import 'data_sha_entity.dart';
import 'data_tachi_entity.dart';
import 'data_sankasha_entity.dart';

class TachiDataObj {
  final TachiData tachiData;
  int _shaInstanceNumber = 0;
  final List<ShaData> shaList = []; //射集合

  int get totalShaNum => shaList.length;
  int get atariShaNum => countAtariSha();
  String get tachiID => tachiData.tachiID;
  SankashaData sankashaData;

  TachiDataObj(tachiID,  gyoshaID,this.sankashaData,{tachiNumber = 0}):
  tachiData = TachiData(tachiID,  gyoshaID, sankashaData.sankashaID,tachiNumber: tachiNumber);

  void createSha(ShaResultType shaResult){
    _shaInstanceNumber++;
    String shaID = tachiID+generateID('S', _shaInstanceNumber);
    var shaData = ShaData(shaID,shaList.length+1,shaResult,tachiID);
    shaList.add(shaData);
  }

  int countAtariSha(){
    return shaList.where((element) => element.shaResult==ShaResultType.atari).length;
  }

  void removeShaAt(String shaID){
    return shaList.removeWhere((element) => element.shaID==shaID);
  }

  }

