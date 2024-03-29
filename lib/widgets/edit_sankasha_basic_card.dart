import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import '../data/data_gyosha_object.dart';

@immutable
class SankashaCardContents extends  ConsumerWidget {
  final int index;
  const SankashaCardContents(this.index, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    GyoshaDataObj editingGyoshaData = ref
        .watch(gyoshaDatasProvider)
        .getEditingGyoshaData();
    var sankashaList = editingGyoshaData.sankashaList;

    void myShowModalBottomSheetSankasha(BuildContext context, [String sankashaID=""]){
      String tempText = "";
      String initName = sankashaID==""? "":
      editingGyoshaData.getSankashaAt(sankashaID).isAppUser==false?
      editingGyoshaData.getSankashaAt(sankashaID).sankashaName:ref.watch(userDatasProvider).userName;

      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('参加者名を入力'),
            content: TextFormField(
              maxLength: 5,
              decoration: const InputDecoration(hintText: '参加者名(5文字まで)'),
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
                      if(editingGyoshaData.getSankashaAt(sankashaID).isAppUser){
                        ref.read(userDatasProvider.notifier).changeName(tempText);
                      }
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

    return LayoutBuilder(builder: (context,constrain){
      return Card(
        key: ValueKey(editingGyoshaData.sankashaList[index].sankashaID),
        child: Row(
          children: [
            SizedBox(
              width: constrain.maxWidth*0.1,
              child: Text((index + 1).toString()),
            ),
            SizedBox(
              width: constrain.maxWidth*0.5,
              child: Text(
                  sankashaList[index].isAppUser==false?sankashaList[index].sankashaName:ref.watch(userDatasProvider).userName,
                  overflow: TextOverflow.ellipsis,
                  style:
                        TextStyle(color: sankashaList[index].isAppUser==true?Theme.of(context).colorScheme.primary:null),
              ),

            ),
            SizedBox(
              width: constrain.maxWidth*0.2,
              child: //sankashaList[index].isAppUser==false?
              ElevatedButton(
                child: const Text('編集'),
                onPressed: () {
                  myShowModalBottomSheetSankasha(context,sankashaList[index].sankashaID);
                },
              ),//:const SizedBox(),
            ),

            SizedBox(
              width: constrain.maxWidth*0.1,
              child: IconButton(
                onPressed: () {
                  if(sankashaList[index].isAppUser==true){
                    editingGyoshaData.deleteAppUserData(recordDB:ref.read(recordDBProvider));
                  }else{
                    editingGyoshaData.removeSankashaAt(sankashaList[index].sankashaID,recordDB:ref.read(recordDBProvider));
                  }
                  ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData,ref);

                },
                icon: const Icon(Icons.delete),
              ),
            ),
          ],
        ),
      );
    });
  }
}




