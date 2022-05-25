import 'data_define.dart';

class SankashaData extends DataAbstClass{
  final String sankashaID;
  final String gyoshaID;
  String sankashaName;
  bool isAppUser;
  SankashaData(this.sankashaID,this.gyoshaID,this.isAppUser,{this.sankashaName = ""});
  @override
  Map<String, dynamic> toMap() {
    return {
      'sankashaID': sankashaID,
      'gyoshaID': gyoshaID,
      'sankashaName': sankashaName,
      'isAppUser': isAppUser,
    };
  }
}