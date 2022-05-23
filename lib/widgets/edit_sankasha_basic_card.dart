import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import '../data/data_gyosha_define.dart';

@immutable
class SankashaCardContents extends  ConsumerWidget {
  final int index;
  const SankashaCardContents(this.index, {Key? key}) : super(key: key);
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
            width: 200,
            child: _DetermineSankashaListItem(index),
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

@immutable
class _DetermineSankashaListItem extends ConsumerWidget{
  final int index;
  const _DetermineSankashaListItem(this.index, {Key? key}) : super(key: key);
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
