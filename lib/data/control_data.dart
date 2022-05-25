import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data_gyosha_object.dart';
import 'data_define.dart';

@immutable
class GyoshaEditManageClass{
  final String? editingGyoshaDataID;
  final List<GyoshaDataObj> gyoshaDataList;

  const GyoshaEditManageClass({required this.editingGyoshaDataID, required this.gyoshaDataList});
  GyoshaEditManageClass copyWith({String? editingGyoshaDataID,List<GyoshaDataObj>? gyoshaDataList}){
    return GyoshaEditManageClass(
        editingGyoshaDataID: editingGyoshaDataID??this.editingGyoshaDataID,
        gyoshaDataList: gyoshaDataList??this.gyoshaDataList);
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
      gyoshaDataList:[]));

  void addGyoshaData(GyoshaDataObj gyoshaDataObj){
    List<GyoshaDataObj> newList = [...state.gyoshaDataList,gyoshaDataObj];
    state = state.copyWith(
        gyoshaDataList: newList);
  }

  void removeGyoshaData(String gyoshaID){
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

  void renewGyoshaData(GyoshaDataObj newGyoshaData){
    List<GyoshaDataObj> newList =state.gyoshaDataList.map((e){
      if(e.gyoshaID==state.editingGyoshaDataID){
        return newGyoshaData;
      }else{
        return e;
      }
    }).toList();

    state = state.copyWith(
        gyoshaDataList: newList,
    );
  }

}

