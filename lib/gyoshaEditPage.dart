import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:kyodoapp/dataDefine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyodoapp/main.dart';
import 'sankashaEditPage.dart';
import 'iconAsset.dart';


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

class GyoshaSettingSliverList extends ConsumerStatefulWidget{
  const GyoshaSettingSliverList({Key? key}) : super(key: key);
  @override
  _GyoshaSettingSliverList createState() => _GyoshaSettingSliverList();
}

class _GyoshaSettingSliverList extends ConsumerState<GyoshaSettingSliverList>{
  String _tempTitle = "";
  final _toggleList = <bool>[false, false, false];

  @override
  void initState() {
    super.initState();
    GyoshaType initType = ref.read(gyoshaDatasProvider).editingGyoshaData.gyoshaType;
    _toggleList[initType.index]=true;
  }

  @override
  Widget build(BuildContext context) {
    GyoshaData editingGyoshaData = ref.watch(gyoshaDatasProvider).editingGyoshaData;

    return SliverList(
      delegate: SliverChildListDelegate(
        [
          TextFormField(
            decoration: const InputDecoration(hintText: 'タイトルを入力'),
            controller: TextEditingController.fromValue(
              TextEditingValue(
                text: editingGyoshaData.gyoshaName,
                selection: TextSelection.collapsed(offset:
                editingGyoshaData.gyoshaName.length),
              ),
            ),
            onChanged: (newValue){
              editingGyoshaData.gyoshaName = newValue;
            },
            onEditingComplete: () {
              FocusScope.of(context).unfocus();
              //editingGyoshaData.gyoshaName =_tempTitle;
              ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData);
            },
          ),
           Center(
             child:
               ToggleButtons(
                    children: const [
                      Icon(Icons.format_italic),
                      Icon(Icons.format_bold),
                      Icon(Icons.format_underlined)
                    ],
                  isSelected: _toggleList,
                   onPressed: (index) {
                     setState(() {
                       for(int i=0;i<_toggleList.length;i++){
                         if(i==index){
                           _toggleList[i] = true;
                         }else{
                           _toggleList[i] = false;
                         }
                         editingGyoshaData.gyoshaType = GyoshaType.values[index];
                         ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData);
                       }
                     });
                   },
                  ),
           ),
          Row(
            children: [
              Flexible(
                child:
                TextButton(
                    onPressed: () {
                      DatePicker.showDateTimePicker(context,
                          showTitleActions: true,
                          minTime: DateTime(2022, 5, 1,12),
                          maxTime: DateTime(2100, 5, 1,12), onChanged: (date) {
                          }, onConfirm: (date) {
                            editingGyoshaData.startDateTime = date;
                              if(editingGyoshaData.finishDateTime.isBefore(editingGyoshaData.startDateTime)){
                                editingGyoshaData.finishDateTime = editingGyoshaData.startDateTime;
                              }
                              ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData);

                          }, currentTime: editingGyoshaData.startDateTime, locale: LocaleType.jp);
                    },
                    child: Text(
                      '練習開始 ${editingGyoshaData.startDateTime.month}/${editingGyoshaData.startDateTime.day} ${editingGyoshaData.startDateTime.hour}:${editingGyoshaData.startDateTime.minute}',
                    )
                ),
              ),
              const Text("-"),
              Flexible(
                child:
                TextButton(
                    onPressed: () {
                      DatePicker.showDateTimePicker(context,
                          showTitleActions: true,
                          minTime: editingGyoshaData.startDateTime,
                          maxTime: DateTime(2100, 5, 1), onChanged: (date) {
                          }, onConfirm: (date) {
                            editingGyoshaData.finishDateTime = date;
                              ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData);

                          }, currentTime: editingGyoshaData.finishDateTime, locale: LocaleType.jp);
                    },
                    child: Text('練習終了 ${editingGyoshaData.finishDateTime.month.toString().padLeft(2,'0')}/${editingGyoshaData.finishDateTime.day.toString().padLeft(2,'0')} ${editingGyoshaData.finishDateTime.hour.toString().padLeft(2,'0')}:${editingGyoshaData.finishDateTime.minute.toString().padLeft(2,'0')} ')
                ),
              ),
              Flexible(
                  child: Text('${editingGyoshaData.renshuHour}時間${editingGyoshaData.renshuMinutes}分'),
              )
            ],
          ),
          Row(
            children: [
              const Text("参加人数"),
              Text('${editingGyoshaData.sankashaNum}'),
              const Text("参加者名"),
              Flexible(child: Wrap(
                  children:
                  [
                    Text(editingGyoshaData.sankashaList.map<String>((SankashaData value) => value.sankashaName).join(', '),
                        overflow: TextOverflow.ellipsis),
                  ]
              ),),

              TextButton(
                child: const Text('編集'),
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context){
                        return const SankashaEditPage();
                      })
                  );
                },
              ),
            ],
          ),

        ]
      ),
    );
  }
}

class GyoshaSliverReorderableListView extends ConsumerStatefulWidget{
  const GyoshaSliverReorderableListView({Key? key}) : super(key: key);
  @override
  _GyoshaSliverReorderableListView createState() => _GyoshaSliverReorderableListView();
}
class _GyoshaSliverReorderableListView extends ConsumerState<GyoshaSliverReorderableListView> {
  double iconSize = 30;
  @override
  Widget build(BuildContext context) {
    GyoshaData editingGyoshaData = ref.watch(gyoshaDatasProvider).editingGyoshaData;
    List<TachiData> editingTachiList = editingGyoshaData.tachiList;

    return SliverReorderableList(
      itemBuilder: (_, index) => ReorderableDelayedDragStartListener(
        index: index,
        key: Key('$index'),
        child: Card(
            child:
            Row(
              children: [
                SizedBox(
                  width: 50.0,
                  height: 80.0,
                  child:Center(
                    child:Text(editingTachiList[index].iteName,overflow: TextOverflow.ellipsis),
                ),
                ),

                Flexible(
                  child:  Wrap(
                    children: <Widget>[
                      for (int i=0;i< editingTachiList[index].shaList.length;i++)
                        SizedBox(
                          width: 50.0,
                          height: 60.0,
                          child:
                            PopupMenuButton(
                              icon: Icon(shaResultMap[editingTachiList[index].shaList[i].shaResult]!.icon,size: iconSize),
                              offset: const Offset(0,0),
                              initialValue: false,
                              onSelected: (shaResult){
                                ShaResultType result = shaResult as ShaResultType;
                                  if(result==ShaResultType.delete){
                                    editingTachiList[index].shaList.removeAt(i);
                                    ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData);
                                  }else{
                                    editingTachiList[index].shaList[i].shaResult=result;
                                    ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData);
                                  }
                              },
                              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                                for(int i=0; i<shaResultMap.length; i++)PopupMenuItem(
                                  child: shaResultMap.values.toList()[i],
                                  value: shaResultMap.keys.toList()[i] ,
                                ),
                              ],
                            ),
                         ),
                      SizedBox(
                        width: 60.0,
                        height: 60.0,
                        child:
                        PopupMenuButton(
                          icon: Icon(Icons.add,size:iconSize),
                          offset: const Offset(0,0),
                          initialValue: false,
                          onSelected: (shaResult){
                            ShaResultType result = shaResult as ShaResultType;

                             if(result==ShaResultType.delete){
                               editingTachiList[index].shaList.removeAt(editingTachiList[index].shaList.length-1);
                               ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData);
                             }else{
                               var newSha = editingTachiList[index].createSha(result);
                               ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData);
                             }

                             if(index==editingTachiList.length-1){
                               editingGyoshaData.addTachi();

                               DateTime now = DateTime.now();
                               if(now.isAfter(editingGyoshaData.finishDateTime)){
                                 editingGyoshaData.finishDateTime = now;
                               }
                               ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData);
                             }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                            for(int i=0; i<shaResultMap.length; i++)PopupMenuItem(
                              child: shaResultMap.values.toList()[i],
                              value: shaResultMap.keys.toList()[i] ,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    editingGyoshaData.removeTachiAt(index);
                     ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData);
                  },
                  icon: const Icon(Icons.delete),
                )
              ],
            ),
        )
      ),
      itemCount: editingTachiList.length,
      onReorder: (int oldIndex, int newIndex) {
        _onReorder(editingTachiList, oldIndex, newIndex);
        ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData);
      },
      proxyDecorator: (widget, _, __) {
        return Opacity(opacity: 0.5, child: widget);
      },
    );
  }

  void _onReorder(List<TachiData> items, int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    items.insert(newIndex, items.removeAt(oldIndex));
  }
}

