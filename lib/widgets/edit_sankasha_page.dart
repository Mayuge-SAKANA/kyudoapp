import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';

import '../data/data_gyosha_object.dart';
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

    bool isAppUserIsSankasha = ref.read(gyoshaDatasProvider).getEditingGyoshaData().isAppUserIsSankasha;
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
    GyoshaDataObj editingGyoshaData = ref
        .watch(gyoshaDatasProvider)
        .getEditingGyoshaData();
    var sankashaList = editingGyoshaData.sankashaList;

    void myShowModalBottomSheetSankasha(BuildContext context, [String sankashaID=""]){
      String tempText = "";
      String initName = sankashaID==""? "":editingGyoshaData.getSankashaAt(sankashaID).sankashaName;
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('参加者名を入力'),
            content: TextFormField(
              maxLength: 5,
              decoration: const InputDecoration(hintText: '参加者名を入力(5文字まで)'),
              controller: TextEditingController.fromValue(
                TextEditingValue(
                  text: initName,
                  selection: TextSelection.collapsed(
                      offset: (initName).length),
                ),
              ),
              onChanged: (newValue){
                tempText = newValue;
              },
              onEditingComplete: () {
                FocusScope.of(context).unfocus();

              },),

            actions: <Widget>[
              TextButton(
                child: const Text('キャンセル'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  if(tempText!=""){
                    if(initName==""){
                      editingGyoshaData.addSankasha(tempText,recordDB:ref.read(recordDBProvider));
                    }else{
                      editingGyoshaData.getSankashaAt(sankashaID).sankashaName=tempText;
                    }
                  }
                  ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData,ref);
                  Navigator.pop(context);
                  //OKを押したあとの処理
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('参加者編集'),
      ),
      body:Column(
        children: [
          const AppUserSankashaCard(),
          Expanded(
            child:
            sankashaList.length==0?
            Text("参加者を入力してください")
            :ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                itemBuilder: (context, index) {
                  return Card(
                    key: ValueKey(sankashaList[index].sankashaID),
                    child: SankashaCardContents(index),
                  );
                },
                itemCount: sankashaList.length,
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    sankashaList.insert(newIndex,sankashaList.removeAt(oldIndex));
                    editingGyoshaData.setSankashaIndex();

                    ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData,ref);
                  });
                },
            ),
          ),


        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: (){
          myShowModalBottomSheetSankasha(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}




