import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import '../data/data_gyosha_define.dart';
import 'edit_sankasha_appusercard.dart';
import 'edit_sankasha_basic_card.dart';

class SankashaEditPage extends ConsumerStatefulWidget{
  const SankashaEditPage({Key? key}) : super(key: key);
  @override
  _SankashaEditPage createState() => _SankashaEditPage();
}

class _SankashaEditPage extends ConsumerState<SankashaEditPage>{
  final _toggleList = <bool>[false,false];
  @override
  void initState() {
    super.initState();
    bool isAppUserIsSankasha = ref.read(gyoshaDatasProvider).editingGyoshaData.isAppUserIsSankasha;
    getToggleList(isAppUserIsSankasha);
  }
  List<bool> getToggleList(bool isAppUserIsSankasha){
    if(isAppUserIsSankasha==true){
      _toggleList[0] = true;
      _toggleList[1] = false;
    }else{
      _toggleList[0] = false;
      _toggleList[1] = true;
    }
    return _toggleList;
  }

  @override
  Widget build(BuildContext context) {
    GyoshaData editingGyoshaData = ref
        .watch(gyoshaDatasProvider)
        .editingGyoshaData;
    var sankashaList = editingGyoshaData.sankashaList;

    return Scaffold(
      appBar: AppBar(
        title: const Text('参加者編集'),
      ),
      body:Column(
        children: [
          const AppUserSankashaCard(),
          Expanded(
            child:  ReorderableListView(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              children: <Widget>[
                for (int index = 0; index < sankashaList.length; index += 1)
                  Card(
                    key: Key('$index'),
                    child: SankashaCardContents(index),
                  ),
              ],
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  sankashaList.insert(newIndex,sankashaList.removeAt(oldIndex));
                  ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData);
                });
              },
            ),
          ),

        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: (){
          bool deleteStopFlag = false;
          for(int i = sankashaList.length-1; i>-1; i--){
            if(deleteStopFlag==true)break;
            if(sankashaList[i].sankashaName==""){
              editingGyoshaData.removeSankashaAt(i);
            }else{
              deleteStopFlag=true;
            }
          }
          editingGyoshaData.addSankasha("", isAppUser: false);
          ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}




