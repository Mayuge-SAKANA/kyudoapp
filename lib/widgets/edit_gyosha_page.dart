import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';

import '../data/data_tachi_define.dart';
import '../data/data_gyosha_define.dart';
import 'edit_gyosha_setting_sliverlist.dart';
import 'edit_gyosha_reordable_listview.dart';



class GyoshaEditPage extends ConsumerWidget{
  const GyoshaEditPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context,WidgetRef ref) {
    GyoshaData editingGyoshaData = ref.watch(gyoshaDatasProvider).editingGyoshaData;
    List<TachiData> editingTachiList = editingGyoshaData.tachiList;
    var _scrollController = ScrollController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('行射記録'),
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.text_snippet),
          ),
        ],
      ),
      body:
      CustomScrollView(
        controller: _scrollController,
        slivers: const [
          GyoshaSettingSliverList(),
          GyoshaSliverReorderableListView(),
        ], //子にSliverたちを並べていく
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          bool deleteStopFlag = false;
          for(int i = editingTachiList.length-1; i>-1; i--){
            if(deleteStopFlag==true)break;
            if(editingTachiList[i].shaList.isEmpty){
              editingGyoshaData.removeTachiAt(i);
            }else{
              deleteStopFlag=true;
            }
          }

          editingGyoshaData.addTachi();
          ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData);

          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.linear,
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}





