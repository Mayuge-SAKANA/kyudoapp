import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import 'edit_sankasha_page.dart';

import '../data/data_define.dart';
import '../data/data_gyosha_object.dart';
import '../data/data_gyosha_entity.dart';
import '../data/data_sankasha_entity.dart';


class GyoshaSettingSliverList extends ConsumerStatefulWidget{
  const GyoshaSettingSliverList({Key? key}) : super(key: key);
  @override
  _GyoshaSettingSliverList createState() => _GyoshaSettingSliverList();
}

class _GyoshaSettingSliverList extends ConsumerState<GyoshaSettingSliverList>{
  final _toggleList = <bool>[false, false, false];
  @override
  void initState() {
    super.initState();
    GyoshaType initType = ref.read(gyoshaDatasProvider).getEditingGyoshaData().gyoshaData.gyoshaType;
    _toggleList[initType.index]=true;
  }
  @override
  Widget build(BuildContext context) {
    GyoshaDataObj editingGyoshaData = ref.watch(gyoshaDatasProvider).getEditingGyoshaData();

    return SliverList(
      delegate: SliverChildListDelegate(
          [
            const GyoshaNameTextFormField(),
            const GyoshaTypeToggleButton(),
            Center(
              child: Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.3,
                    child: const StartTimeTextColumn(),),
                  const Text("-"),
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.3,
                    child: const FinishTimeTextColumn(),),
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.3,
                      child: Center(
                        child: FittedBox(child:
                          Text('${editingGyoshaData.renshuHour}時間${editingGyoshaData.renshuMinutes}分')
                          ,),
                      ),
                  ),
                ],
              ),
            ),
            const SankashaEditRow(),
          ]
      ),
    );
  }
}

class GyoshaNameTextFormField extends ConsumerStatefulWidget{
  const GyoshaNameTextFormField({Key? key}) : super(key: key);
  @override
  _GyoshaNameTextFormField createState() => _GyoshaNameTextFormField();
}

class _GyoshaNameTextFormField extends ConsumerState<GyoshaNameTextFormField>{

  @override
  Widget build(BuildContext context){
    GyoshaDataObj editingGyoshaData = ref.watch(gyoshaDatasProvider).getEditingGyoshaData();
    GyoshaData gyoshaData = editingGyoshaData.gyoshaData;

    void myShowModalBottomSheet(BuildContext context){
      String tempText = "";
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('行射名を入力'),
            content: TextFormField(
              decoration: const InputDecoration(hintText: 'タイトルを入力'),
              controller: TextEditingController.fromValue(
                TextEditingValue(
                  text: gyoshaData.gyoshaName,
                  selection: TextSelection.collapsed(offset:
                  gyoshaData.gyoshaName.length),
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
                  if(tempText!="") gyoshaData.gyoshaName = tempText;
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


    return LayoutBuilder(builder: (context, constrain){
      return Row(
        children: [
          SizedBox(
          width: constrain.maxWidth*0.8,
          child: Text(gyoshaData.gyoshaName ),
          ),
          SizedBox(
            width: constrain.maxWidth*0.2,
            child: ElevatedButton(
              child: const Text('編集'),
              onPressed: () {
                myShowModalBottomSheet(context);
              },
            ),),
        ],
      );
    });
  }
}

class GyoshaTypeToggleButton extends ConsumerStatefulWidget{
  const GyoshaTypeToggleButton({Key? key}) : super(key: key);
  @override
  _GyoshaTypeToggleButton createState() => _GyoshaTypeToggleButton();
}

class _GyoshaTypeToggleButton extends ConsumerState<GyoshaTypeToggleButton> {
  final _toggleList = <bool>[false, false, false];
  @override
  void initState() {
    super.initState();
    GyoshaType initType = ref.read(gyoshaDatasProvider).getEditingGyoshaData().gyoshaData.gyoshaType;
    _toggleList[initType.index]=true;
  }
  @override
  Widget build(BuildContext context){
    GyoshaDataObj editingGyoshaData = ref.watch(gyoshaDatasProvider).getEditingGyoshaData();
    GyoshaData gyoshaData = editingGyoshaData.gyoshaData;
    return Center(
      child:
      ToggleButtons(
        children: const [
          Text("練習"),
          Text("射会"),
          Text("試合")
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
              gyoshaData.gyoshaType = GyoshaType.values[index];
              ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData,ref);
            }
          });
        },
      ),
    );
  }
}


class StartTimeTextColumn extends ConsumerWidget{
  const StartTimeTextColumn({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context,WidgetRef ref){
    GyoshaDataObj editingGyoshaData = ref.watch(gyoshaDatasProvider).getEditingGyoshaData();
    GyoshaData gyoshaData = editingGyoshaData.gyoshaData;
    return TextButton(
          onPressed: () {
            DatePicker.showDateTimePicker(context,
                showTitleActions: true,
                minTime: DateTime(2022, 5, 1,12),
                maxTime: DateTime(2100, 5, 1,12), onChanged: (date) {
                }, onConfirm: (date) {
                  gyoshaData.startDateTime = date;
                  if(gyoshaData.finishDateTime.isBefore(gyoshaData.startDateTime)){
                    gyoshaData.finishDateTime = gyoshaData.startDateTime;
                  }
                  ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData,ref);

                }, currentTime: gyoshaData.startDateTime, locale: LocaleType.jp);
          },
          child: Column(
            children: [
              const Text('練習開始'),
              Text('${gyoshaData.startDateTime.month.toString().padLeft(2,'0')}/${gyoshaData.startDateTime.day.toString().padLeft(2,'0')} ${gyoshaData.startDateTime.hour.toString().padLeft(2,'0')}:${gyoshaData.startDateTime.minute.toString().padLeft(2,'0')}'),
            ],
          )
      );
  }
}

class FinishTimeTextColumn extends ConsumerWidget{
  const FinishTimeTextColumn({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref){
    GyoshaDataObj editingGyoshaData = ref.watch(gyoshaDatasProvider).getEditingGyoshaData();
    GyoshaData gyoshaData = editingGyoshaData.gyoshaData;
    return
      TextButton(
          onPressed: () {
            DatePicker.showDateTimePicker(context,
                showTitleActions: true,
                minTime: gyoshaData.startDateTime,
                maxTime: DateTime(2100, 5, 1), onChanged: (date) {
                }, onConfirm: (date) {
                  gyoshaData.finishDateTime = date;
                  ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData,ref);
                }, currentTime: gyoshaData.finishDateTime, locale: LocaleType.jp);
          },
          child: Column(
            children: [
              const Text('練習終了'),
              Text('${gyoshaData.finishDateTime.month.toString().padLeft(2,'0')}/${gyoshaData.finishDateTime.day.toString().padLeft(2,'0')} ${gyoshaData.finishDateTime.hour.toString().padLeft(2,'0')}:${gyoshaData.finishDateTime.minute.toString().padLeft(2,'0')} ')
            ],
          )
      );
  }
}

class SankashaEditRow extends ConsumerWidget{
  const SankashaEditRow({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref){
    GyoshaDataObj editingGyoshaData = ref.watch(gyoshaDatasProvider).getEditingGyoshaData();
    return LayoutBuilder(builder: (context, constrain){
      return Row(
        children: [
          SizedBox(
            width: constrain.maxWidth*0.2,
            child: const Center(child: Text("参加人数"),),
          ),
          SizedBox(
            width: constrain.maxWidth*0.1,
            child: Center(child: Text('${editingGyoshaData.sankashaNum}人'),),
          ),
          SizedBox(
            width: constrain.maxWidth*0.5,
            child: Text(editingGyoshaData.sankashaList.map<String>((SankashaData value) => value.sankashaName==""? "名無し": value.sankashaName).join(', '),
                overflow: TextOverflow.ellipsis),
          ),
          SizedBox(
            width: constrain.maxWidth*0.2,
            child: ElevatedButton(
              child: const Text('編集'),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context){
                      return const SankashaEditPage();
                    })
                );
              },
            ),)
        ],
      );
    } );

  }

}







