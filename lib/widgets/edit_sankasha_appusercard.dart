import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import '../data/data_gyosha_object.dart';

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
    bool isAppUserIsSankasha = ref.read(gyoshaDatasProvider).getEditingGyoshaData().isAppUserIsSankasha;
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
    GyoshaDataObj editingGyoshaData = ref
        .watch(gyoshaDatasProvider)
        .getEditingGyoshaData();
    return LayoutBuilder(builder: (context,constrain){
      return  Row(
          children: [

            SizedBox(
              width:constrain.maxWidth*0.6,
              child: Text("あなた：${ref.watch(userDatasProvider).userName}"),
            ),
            SizedBox(
              width: constrain.maxWidth*0.35,
              child: ToggleButtons(
                isSelected: getToggleList(editingGyoshaData.isAppUserIsSankasha),
                onPressed: (index) {
                  setState(() {
                    for(int i=0;i<_toggleList.length;i++){
                        _toggleList[i] = !_toggleList[i];
                    }
                    if(_toggleList[0]==true){
                      editingGyoshaData.addAppUserToSankasha(recordDB:ref.read(recordDBProvider));
                    }else{
                      editingGyoshaData.deleteAppUserData(recordDB:ref.read(recordDBProvider));
                    }
                    ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData,ref);
                  });
                },
                children: const [
                  Text("参加"),
                  Text("不参加"),
                ],
              ),
            ),


          ],
        );
    });


  }


}