import 'data_define.dart';

class SankashaData extends DataAbstClass{
  String sankashaID;
  String gyoshaID;
  String sankashaName;
  bool isAppUser;
  int sankashaNumber;
  SankashaData(this.sankashaID,this.gyoshaID,this.isAppUser,{this.sankashaName = "", this.sankashaNumber=0});
  @override
  Map<String, dynamic> toMap() {
    return {
      'sankashaID': sankashaID,
      'gyoshaID': gyoshaID,
      'sankashaName': sankashaName,
      'isAppUser': isAppUser?1:0,
      'sankashaNumber': sankashaNumber,
    };
  }
}