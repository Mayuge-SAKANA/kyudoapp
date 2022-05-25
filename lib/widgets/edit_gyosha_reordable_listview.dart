import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import '../data/data_define.dart';
import '../data/data_gyosha_object.dart';
import '../data/data_tachi_object.dart';
import 'icon_asset.dart';


class GyoshaSliverReorderableListView extends ConsumerStatefulWidget{
  const GyoshaSliverReorderableListView({Key? key}) : super(key: key);
  @override
  _GyoshaSliverReorderableListView createState() => _GyoshaSliverReorderableListView();
}
class _GyoshaSliverReorderableListView extends ConsumerState<GyoshaSliverReorderableListView> {
  double iconSize = 30;
  @override
  Widget build(BuildContext context) {
    GyoshaDataObj editingGyoshaData = ref.watch(gyoshaDatasProvider).getEditingGyoshaData();
    List<TachiDataObj> editingTachiList = editingGyoshaData.tachiList;

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
                    child:Text(editingTachiList[index].sankashaData.sankashaName,overflow: TextOverflow.ellipsis),
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
                              editingTachiList[index].createSha(result);
                              ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData);
                            }

                            if(index==editingTachiList.length-1){
                              editingGyoshaData.addTachi();

                              DateTime now = DateTime.now();
                              if(now.isAfter(editingGyoshaData.gyoshaData.finishDateTime)){
                                editingGyoshaData.gyoshaData.finishDateTime = now;
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
                    editingGyoshaData.removeTachiAt(editingTachiList[index].tachiID);
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

  void _onReorder(List<TachiDataObj> items, int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    items.insert(newIndex, items.removeAt(oldIndex));
  }
}