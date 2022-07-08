import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';

class ProfileSetting extends ConsumerWidget{
  String? tempText;

  ProfileSetting({Key? key}) : super(key: key);
  List<Color> colorList = [
    Color(0x00c14333),
    Color(0x00094F6A),
    Color(0x0058456b),
    Color(0x00ccab09)
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref){
    bool _isOn = ref.watch(userDatasProvider).isDark;
    return Scaffold(
      appBar: AppBar(
        title: Text("プロフィール設定"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 50,),
              Text("名前の設定",style: TextStyle(fontSize: 20),),
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
              ),

              SizedBox(height: 50,),
              Text("ダークモード: "+(_isOn?"ON":"OFF"),style: TextStyle(fontSize: 20),),
              Switch(
                activeColor:  Theme.of(context).colorScheme.primary,
                activeTrackColor:  Theme.of(context).colorScheme.primaryContainer,
                inactiveThumbColor: Theme.of(context).colorScheme.primary,
                value: _isOn,
                onChanged: (value) {
                  _isOn = value;
                  ref.watch(userDatasProvider.notifier).changeDark(_isOn);
                },
              ),

              SizedBox(height: 50,),
              Text("色",style: TextStyle(fontSize: 20),),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(colorList.length, (index) {
                    return Padding(
                      padding: EdgeInsets.all(10),
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: Material(
                          borderRadius: BorderRadius.circular(25.0),
                          color: colorList[index].withOpacity(1),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(25.0),
                            onTap: () {
                              ref.read(userDatasProvider.notifier).changeColor(colorList[index]);
                              print("tapped");
                            },
                          ),
                        ),
                      ),
                    );
                  }
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}