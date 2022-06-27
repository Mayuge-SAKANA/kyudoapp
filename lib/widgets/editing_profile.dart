import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';

class ProfileSetting extends ConsumerWidget{
  String? tempText;
  ProfileSetting({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref){

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Text("あなたの名前を入力してください"),
            Text("現在の設定："+ref.watch(userDatasProvider).userName),
            TextFormField(
              maxLength: 5,
              decoration: const InputDecoration(hintText: '名前を入力(5文字まで)'),
              controller: TextEditingController.fromValue(
                TextEditingValue(
                  text: ref.watch(userDatasProvider).userName,
                  selection: TextSelection.collapsed(
                    offset: ref.watch(userDatasProvider).userName.length,
                  ),
                ),
              ),
              onChanged: (newValue){
                tempText = newValue;
              },
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
              },),
            ElevatedButton(
              child: const Text('登録'),
              onPressed: () {
                ref.read(userDatasProvider.notifier).changeName(tempText??"");
              },
            )



          ],
        ),
      ),
    );
  }

}