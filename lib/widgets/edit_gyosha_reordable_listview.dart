import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyodoapp/data/db_define.dart';
import '../main.dart';
import '../data/data_define.dart';
import '../data/data_gyosha_object.dart';
import '../data/data_tachi_object.dart';
import 'icon_asset.dart';
import '../data/data_sha_entity.dart';


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
    double dataHeight = MediaQuery.of(context).size.height*0.1;
    return SliverReorderableList(

      itemBuilder: (_, index) => ReorderableDelayedDragStartListener(
          index: index,
          key: ValueKey(index ==editingTachiList.length?"":editingTachiList[index].tachiID),
          child: index ==editingTachiList.length?
          SizedBox(height: MediaQuery.of(context).size.height*0.3)
          :Card(
            child:
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.15,
                  height: dataHeight,
                  child: NameSpace(editingTachiList[index].sankashaData.isAppUser?ref.watch(userDatasProvider).userName:editingTachiList[index].sankashaData.sankashaName),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.7,
                  child: ScoreEditSpace(index),
                ),

                SizedBox(
                  width: MediaQuery.of(context).size.width*0.1,
                  height: dataHeight,
                  child: IconButton(
                    onPressed: () async{
                      await editingGyoshaData.removeTachiAt(editingTachiList[index].tachiID,recordDB:ref.read(recordDBProvider));
                      ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData,ref);
                    },
                    icon: const Icon(Icons.delete),
                  ),
                )
              ],
            ),
          )
      ),
      itemCount: editingTachiList.length+1,
      onReorder: (int oldIndex, int newIndex) {
        _onReorder(editingTachiList, oldIndex, newIndex);
        editingGyoshaData.setTachiIndex();
        ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData,ref);
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

class NameSpace extends StatelessWidget{
  final String viewName;
  const NameSpace(this.viewName,{Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context){
    return Center(
      child:Text(viewName==""? "名無し": viewName,overflow: TextOverflow.ellipsis),
    );
  }
}
class ScoreEditSpace extends ConsumerWidget {
  final int index;
  const ScoreEditSpace(this.index,{Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref){
    GyoshaDataObj editingGyoshaData = ref.watch(gyoshaDatasProvider).getEditingGyoshaData();
    TachiDataObj editingTachi = editingGyoshaData.tachiList[index];

    void _setData(){
      ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData,ref);
    }

    return LayoutBuilder(builder: (context, constrain){
      return Wrap(
        children: <Widget>[
          ...editingTachi.shaList.map((shaData) {
            void _deleteItem(){
              editingTachi.removeShaAt(shaData.shaID);
              _setData();
            }
            return SizedBox(
              width: constrain.maxWidth/5,
              height: constrain.maxWidth/5,
              child: SelectPopUpMenuButton(shaData,_deleteItem,_setData),
            );
          }).toList(),

          SizedBox(
            width: constrain.maxWidth/5,
            height: constrain.maxWidth/5,
            child: AddPopUpMenuButton(index),
          ),
        ],
      );
    });
  }
}

class SelectPopUpMenuButton extends StatelessWidget{
  final VoidCallback _deleteItem;
  final VoidCallback _setData;
  final ShaData shaData;
  const SelectPopUpMenuButton(this.shaData,this._deleteItem,this._setData,{Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context){
    return PopupMenuButton(
      icon: Icon(shaResultMap[shaData.shaResult]!.icon),
      offset: const Offset(0,0),
      initialValue: false,
      onSelected: (shaResult){
        ShaResultType result = shaResult as ShaResultType;
        if(result==ShaResultType.delete){
          _deleteItem();
        }else{
          shaData.shaResult=result;
          _setData();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
        for(int i=0; i<shaResultMap.length; i++)PopupMenuItem(
          child: shaResultMap.values.toList()[i],
          value: shaResultMap.keys.toList()[i] ,
        ),
      ],
    );
  }
}

class AddPopUpMenuButton extends ConsumerWidget{
  final int index;
  const AddPopUpMenuButton(this.index, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref){
    GyoshaDataObj editingGyoshaData = ref.watch(gyoshaDatasProvider).getEditingGyoshaData();
    List<TachiDataObj> editingTachiList = editingGyoshaData.tachiList;
    TachiDataObj editingTachi = editingGyoshaData.tachiList[index];
    RecordDB db = ref.read(recordDBProvider);

    void _setData(){
      ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData,ref);
    }
    return PopupMenuButton(
      icon: const Icon(Icons.add),
      offset: const Offset(0,0),
      initialValue: false,
      onSelected: (shaResult)async{
        ShaResultType result = shaResult as ShaResultType;

        if(result==ShaResultType.delete){
          editingTachi.shaList.removeAt(editingTachi.shaList.length-1);
          _setData();
        }else {
          editingTachi.addSha(result, db: db);
          _setData();
        }
        if(index==editingTachiList.length-1){
          await editingGyoshaData.addTachi(recordDB:ref.read(recordDBProvider));

          DateTime now = DateTime.now();
          if(now.isAfter(editingGyoshaData.gyoshaData.finishDateTime)){
            editingGyoshaData.gyoshaData.finishDateTime = now;
          }
          _setData();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
        for(int i=0; i<shaResultMap.length; i++)PopupMenuItem(
          child: shaResultMap.values.toList()[i],
          value: shaResultMap.keys.toList()[i] ,
        ),
      ],
    );

  }


}