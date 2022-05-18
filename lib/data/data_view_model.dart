import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data_gyosha_define.dart';

@immutable
class GyoshaEditManageClass{
  final int editingGyoshaDataIndex;
  final List<GyoshaData> gyoshaDataList;
  GyoshaData get editingGyoshaData =>gyoshaDataList[editingGyoshaDataIndex];

  const GyoshaEditManageClass({required this.editingGyoshaDataIndex, required this.gyoshaDataList});
  GyoshaEditManageClass copyWith({int? editingGyoshaDataIndex,List<GyoshaData>? gyoshaDataList}){
    return GyoshaEditManageClass(
        editingGyoshaDataIndex: editingGyoshaDataIndex??this.editingGyoshaDataIndex,
        gyoshaDataList: gyoshaDataList??this.gyoshaDataList);
  }
}

class GyoshaDatasNotifier extends StateNotifier<GyoshaEditManageClass>{
  GyoshaDatasNotifier(): super(const GyoshaEditManageClass(
      editingGyoshaDataIndex:0,
      gyoshaDataList:[]));

  void addGyoshaData(GyoshaData gyoshaData){
    List<GyoshaData> newList = [...state.gyoshaDataList,gyoshaData];
    state = state.copyWith(
        gyoshaDataList: newList);
  }

  void removeGyoshaData(int index){
    state = state.copyWith(
      gyoshaDataList: [
        for(int i=0;i<state.gyoshaDataList.length;i++)
          if(i!=index)state.gyoshaDataList[i]
      ]
    );
  }
  void setEditingGyoshaData(int index){
    state = state.copyWith(
      editingGyoshaDataIndex: index
    );
  }

  void renewGyoshaData(GyoshaData newGyoshaData){
    state = state.copyWith(
        gyoshaDataList: [
          for(int i=0;i<state.gyoshaDataList.length;i++)
            if(i==state.editingGyoshaDataIndex) newGyoshaData
            else state.gyoshaDataList[i]
        ]
    );
  }

}

