import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import '../data/data_gyosha_define.dart';

class AppUserSankashaCard extends ConsumerStatefulWidget{
  const AppUserSankashaCard({Key? key}) : super(key: key);
  @override
  _AppUserSankashaCardState createState() => _AppUserSankashaCardState();
}

class _AppUserSankashaCardState extends ConsumerState<AppUserSankashaCard> {
  final _toggleList = <bool>[false,false];
  @override
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
    return Card(
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
    );

  }


}