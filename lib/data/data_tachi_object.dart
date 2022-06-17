import 'db_define.dart';

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

  void addSha(ShaResultType shaResult ,{RecordDB? db}) async{
    ShaData shaData;

    _shaInstanceNumber++;
    String shaID = tachiID+generateID('TEST', _shaInstanceNumber);
    shaData = ShaData(shaID,shaList.length+1,shaResult,tachiID);
    shaList.add(shaData);

    if(db!=null){
      var dbId = await db.insertData('sha_data', shaData);
      String shaID = tachiID+generateID('S', dbId);
      shaData.shaID = shaID;
      db.updateData('sha_data', 'id', dbId, shaData);
      shaList.last.shaID =shaID;
    }

  }

  int countAtariSha(){
    return shaList.where((element) => element.shaResult==ShaResultType.atari).length;
  }

  void removeShaAt(String shaID,{RecordDB? db}){
    if(db!=null){
      db.deleteData('sha_table', 'shaID', shaID);
    }
    return shaList.removeWhere((element) => element.shaID==shaID);
  }

  }

