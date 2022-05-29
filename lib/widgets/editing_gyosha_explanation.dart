import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import '../data/data_gyosha_object.dart';

class EditingGyoshaText extends ConsumerWidget{
  const EditingGyoshaText({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context,WidgetRef ref){
    GyoshaDataObj editingGyoshaData = ref
        .watch(gyoshaDatasProvider)
        .getEditingGyoshaData();
    String tempText = editingGyoshaData.gyoshaData.memoText??"";
    return Scaffold(
      appBar: AppBar(
        title: const Text("メモを入力"),
        actions: [
          ElevatedButton(
              onPressed: (){
                if(tempText!="") editingGyoshaData.gyoshaData.memoText = tempText;
                ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData);
                Navigator.pop(context);

              },
              child: const Text("保存"),)
        ]
      ),
      body:  TextFormField(
        minLines: 1000,
        maxLines: null,
        decoration: const InputDecoration(hintText: 'メモを入力'),
        controller: TextEditingController.fromValue(
          TextEditingValue(
            text: tempText,
            selection: TextSelection.collapsed(
                offset: (tempText).length),
          ),
        ),
        onChanged: (newValue){
          tempText = newValue;
        },
        onEditingComplete: () {
          FocusScope.of(context).unfocus();
        },),
    );

  }


}
