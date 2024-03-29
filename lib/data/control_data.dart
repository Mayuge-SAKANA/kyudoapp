

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyodoapp/data/db_define.dart';
import 'data_gyosha_object.dart';
import '../main.dart';
import 'data_define.dart';

@immutable
class GyoshaEditManageClass{
  final String? editingGyoshaDataID;
  final List<GyoshaDataObj> gyoshaDataList;

  const GyoshaEditManageClass({required this.editingGyoshaDataID, required this.gyoshaDataList});
  GyoshaEditManageClass copyWith({String? editingGyoshaDataID,List<GyoshaDataObj>? gyoshaDataList}){
    return GyoshaEditManageClass(
        editingGyoshaDataID: editingGyoshaDataID??this.editingGyoshaDataID,
        gyoshaDataList: gyoshaDataList??this.gyoshaDataList,
    );
  }

  GyoshaDataObj getEditingGyoshaData(){
    GyoshaDataObj editingGyoshaData = gyoshaDataList.firstWhere((element){
      return element.gyoshaID==editingGyoshaDataID;});
    return editingGyoshaData;
  }
}

class GyoshaDatasNotifier extends StateNotifier<GyoshaEditManageClass>{
  GyoshaDatasNotifier(): super(const GyoshaEditManageClass(
      editingGyoshaDataID:"",
      gyoshaDataList:[]),
  );


  void createAndAddGyoshaData(WidgetRef ref,
  {initialGyoshaName = "今日の行射", gyoshaEnKin = GyoshaEnKin.kinteki})async{

    RecordDB recordDB = ref.watch(recordDBProvider);

    DateTime startTime = DateTime.now();
    var gyoshaDataObj = GyoshaDataObj("ユーザ名",initialGyoshaName,GyoshaType.renshu,startTime,startTime,
        recordDB: ref.read(recordDBProvider),gyoshaEnKin: gyoshaEnKin);
    await gyoshaDataObj.addSankasha("ユーザ名",isAppUser: true, recordDB: recordDB);


    var dbId = await recordDB.insertData('gyosha_data', gyoshaDataObj.gyoshaData);

    String newGyoshaID = generateID('G', dbId);
    gyoshaDataObj.gyoshaData.gyoshaID = newGyoshaID;


    gyoshaDataObj.sankashaList[0].gyoshaID = newGyoshaID;
    await gyoshaDataObj.addTachi(recordDB: recordDB);

    //List<GyoshaDataObj> newList = [...state.gyoshaDataList,gyoshaDataObj];
    List<GyoshaDataObj> newList = [];
    newList = sortGyoshaData(gyoshaDataObj);

    state = state.copyWith(
        gyoshaDataList: newList);

    recordDB.updateData('gyosha_data', 'id', dbId, gyoshaDataObj.gyoshaData);
    recordDB.updateData('sankasha_data', 'sankashaID', gyoshaDataObj.sankashaList[0].sankashaID, gyoshaDataObj.sankashaList[0]);
  }



  void removeGyoshaData(String gyoshaID,WidgetRef ref) async{

    await ref.watch(recordDBProvider).deleteGyoshaData(
      state.gyoshaDataList.firstWhere((element) => element.gyoshaID==gyoshaID)
    );
    state = state.copyWith(
        gyoshaDataList: [
          ...state.gyoshaDataList.where((item){
            return item.gyoshaID!=gyoshaID;
          }),
        ]
    );


  }

  void setEditingGyoshaData(String gyoshaID){
    state = state.copyWith(
        editingGyoshaDataID: gyoshaID
    );
  }

  void renewGyoshaData(GyoshaDataObj newGyoshaData, WidgetRef ref){
    List<GyoshaDataObj> newList =state.gyoshaDataList.map((e){
      if(e.gyoshaID==state.editingGyoshaDataID){
        return newGyoshaData;
      }else{
        return e;
      }
    }).toList();

    state = state.copyWith(
        gyoshaDataList: newList);

    newList = sortGyoshaData(newGyoshaData);

    state = state.copyWith(
        gyoshaDataList: newList,
    );

    ref.watch(recordDBProvider).updateGyoshaData(newGyoshaData);
    
  }

  void loadGyoshaList(WidgetRef ref) async{
    var newList =await ref.watch(recordDBProvider).getGyoshaDataObjList();
    state = state.copyWith(
      gyoshaDataList: newList,
    );
  }

  List<GyoshaDataObj> sortGyoshaData(GyoshaDataObj newData){
    List<GyoshaDataObj> newList = [];
    bool addFlag = true;

    if(state.gyoshaDataList.isEmpty){
      return [newData];
    }

    state.gyoshaDataList.removeWhere((element) => element.gyoshaID==newData.gyoshaID);


    for(int i=0;i<state.gyoshaDataList.length;i++){
      var gyoshaDataObj = state.gyoshaDataList[i];

      if(i==0&&newData.gyoshaData.startDateTime.isAfter(gyoshaDataObj.gyoshaData.startDateTime)){
        newList.add(newData);
        addFlag = false;
      } else if(addFlag&&newData.gyoshaData.startDateTime.isAfter(gyoshaDataObj.gyoshaData.startDateTime)){
        newList.add(newData);
        addFlag = false;
      }else if(addFlag&&newData.gyoshaData.startDateTime==gyoshaDataObj.gyoshaData.startDateTime){
        newList.add(newData);
        addFlag = false;
      }
      newList.add(gyoshaDataObj);
    }
    if(addFlag){
      newList.add(newData);
    }


    return newList;
  }

}

