import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';

import '../data/data_tachi_object.dart';
import '../data/data_gyosha_object.dart';
import 'edit_gyosha_setting_sliverlist.dart';
import 'edit_gyosha_reordable_listview.dart';

import 'editing_gyosha_explanation.dart';

class GyoshaEditPage extends ConsumerWidget{
  const GyoshaEditPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context,WidgetRef ref) {
    GyoshaDataObj editingGyoshaData = ref.watch(gyoshaDatasProvider).getEditingGyoshaData();
    List<TachiDataObj> editingTachiList = editingGyoshaData.tachiList;
    var _scrollController = ScrollController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('行射記録'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context){
                    return const EditingGyoshaText();
                  })
              );
            },
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
        onPressed: () async{
          await editingGyoshaData.addTachi(recordDB:ref.read(recordDBProvider));
          ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData,ref);

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





