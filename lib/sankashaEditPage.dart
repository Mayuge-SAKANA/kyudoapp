import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:kyodoapp/dataDefine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyodoapp/main.dart';

class SankashaEditPage extends ConsumerStatefulWidget{
  const SankashaEditPage({Key? key}) : super(key: key);
  @override
  _SankashaEditPage createState() => _SankashaEditPage();
}

class _SankashaEditPage extends ConsumerState<SankashaEditPage>{
  final _toggleList = <bool>[false,false];
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
    var _scrollController = ScrollController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('参加者編集'),
      ),
      body:Column(
        children: [
          Card(
          child: Row(
            children: [
              Flexible(child:
                Wrap(
                  children: [
                    Text(editingGyoshaData.appUserData!.sankashaName),
                  ],
                )
              ),

              const SizedBox(
                width: 50.0,
                height: 60.0,
              ),

              ToggleButtons(
                children: const [
                  Text("参加"),
                  Text("不参加"),
                ],
                isSelected: getToggleList(editingGyoshaData.isAppUserIsSankasha),
                onPressed: (index) {
                  setState(() {
                    for(int i=0;i<_toggleList.length;i++){
                      if(i==index){
                        _toggleList[i] = true;
                      }else{
                        _toggleList[i] = false;
                      }
                      if(_toggleList[0]==true){
                        editingGyoshaData.addAppUserToSankasha();
                      }else{
                        editingGyoshaData.deleteAppUserData();
                      }
                      ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData);
                    }
                  });
                },
              ),

              const SizedBox(
                width: 50.0,
                height: 60.0,
              )
            ],
          ),
        ),

          Expanded(
            child:  ReorderableListView(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              children: <Widget>[
                for (int index = 0; index < sankashaList.length; index += 1)
                  Card(
                    key: Key('$index'),
                    child: _SankashaCardContents(index),
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

class _SankashaCardContents extends  ConsumerWidget {
  int index;
  _SankashaCardContents(this.index, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    GyoshaData editingGyoshaData = ref
        .watch(gyoshaDatasProvider)
        .editingGyoshaData;
    var sankashaList = editingGyoshaData.sankashaList;

    return Card(
      key: Key('$index'),
      child: Row(
        children: [
          Text((index + 1).toString().padLeft(3)),
          const SizedBox(
            width: 20.0,
            //height: 60.0,
          ),
          SizedBox(
            //height: 60,
            width: 240,
            child: _determineSankashaListItem(index),
          ),

          IconButton(
            onPressed: () {
              if(sankashaList[index].isAppUser==true){
                editingGyoshaData.isAppUserIsSankasha = false;
              }
              editingGyoshaData.removeSankashaAt(index);
              ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData);
            },
            icon: const Icon(Icons.delete),
          ),
          const SizedBox(
            width: 50.0,
            //height: 60.0,
          )
        ],
      ),
    );
  }
}

class _determineSankashaListItem extends ConsumerWidget{
  int index;
  _determineSankashaListItem(this.index, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context,WidgetRef ref){
    GyoshaData editingGyoshaData = ref
        .watch(gyoshaDatasProvider)
        .editingGyoshaData;
    var sankashaList = editingGyoshaData.sankashaList;
    if(sankashaList[index].isAppUser==false){
     return TextFormField(
        controller: TextEditingController.fromValue(
          TextEditingValue(
            text: sankashaList[index].sankashaName,
            selection: TextSelection.collapsed(offset:
            sankashaList[index].sankashaName.length),
          ),
        ),

        decoration: const InputDecoration(hintText: '名前を入力'),
        onChanged: (newValue){
          sankashaList[index].sankashaName = newValue;
        },
        onEditingComplete: () {
          FocusScope.of(context).unfocus();
          ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData);
        },
      );
    }
    return Text(sankashaList[index].sankashaName,overflow: TextOverflow.ellipsis);
  }
}
