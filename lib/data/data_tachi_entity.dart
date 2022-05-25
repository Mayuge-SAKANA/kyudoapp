import 'data_define.dart';

class TachiData extends DataAbstClass {
  final String tachiID; //立固有ID
  int tachiNumber; //練習中何番目の立ちか
  final String gyoshaID; //行射固有ID
  String sankashaID;

  TachiData(this.tachiID,  this.gyoshaID,this.sankashaID,{this.tachiNumber = 0});
  @override
  Map<String, dynamic> toMap() {
    return {
      'tachiID': tachiID, //立固有ID
      'tachiNumber': tachiNumber, //練習中何番目の立ちか
      'gyoshaID': gyoshaID, //行射固有ID
      'sankashaID': sankashaID, //行射固有ID
    };
  }
}
