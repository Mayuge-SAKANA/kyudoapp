import 'data_define.dart';

class GyoshaData extends DataAbstClass {
  final String gyoshaID; //行射固有ID
  final String mainEditorName; // 編集者名
  final GyoshaState gyoshaState; //オンラインオフライン
  String gyoshaName; //行射タイトル
  GyoshaType gyoshaType; //行射種類
  DateTime startDateTime;//開始時間
  DateTime finishDateTime; //終了時間
  String? memoText; //メモ内容

  String get startDateTimeStr =>dateTimeToString(startDateTime); //開始時間
  String get finishDateTimeStr => dateTimeToString(finishDateTime); //終了時間


  GyoshaData(this.gyoshaID,this.mainEditorName, this.gyoshaName,
       this.startDateTime,this.finishDateTime,
      {this.gyoshaType = GyoshaType.renshu,this.gyoshaState = GyoshaState.offline});



  @override
  Map<String, dynamic> toMap() {
    return {
      'gyoshaID': gyoshaID, //行射固有ID
      'mainEditorName': mainEditorName, // 編集者名
      'gyoshaState':gyoshaState.index, //オンラインオフライン
      'gyoshaName': gyoshaName,//行射タイトル
      'gyoshaType': gyoshaType.index, //行射種類
      'startYear':startDateTime.year,//開始時間
      'startMonth':startDateTime.month,//開始時間
      'startDay':startDateTime.day,//開始時間
      'startHour':startDateTime.hour,//開始時間
      'startMinute':startDateTime.minute,//開始時間
      'finishYear':finishDateTime.year,//終了時間
      'finishMonth':finishDateTime.month,//終了時間
      'finishDay':finishDateTime.day,//終了時間
      'finishHour':finishDateTime.hour,//終了時間
      'finishMinute':finishDateTime.minute,//終了時間
      'memoText':memoText,//メモ内容
    };
  }
}

