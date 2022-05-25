import 'data_define.dart';

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