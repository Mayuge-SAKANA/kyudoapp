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
    GyoshaData gyoshaData = editingGyoshaData.gyoshaData;

    return SliverList(
      delegate: SliverChildListDelegate(
          [
            TextFormField(
              decoration: const InputDecoration(hintText: 'タイトルを入力'),
              controller: TextEditingController.fromValue(
                TextEditingValue(
                  text: gyoshaData.gyoshaName,
                  selection: TextSelection.collapsed(offset:
                  gyoshaData.gyoshaName.length),
                ),
              ),
              onChanged: (newValue){
                gyoshaData.gyoshaName = newValue;
              },
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
                ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData);
              },
            ),
            Center(
              child:
              ToggleButtons(
                children: const [
                  Icon(Icons.format_italic),
                  Icon(Icons.format_bold),
                  Icon(Icons.format_underlined)
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
                      ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData);
                    }
                  });
                },
              ),
            ),
            Row(
              children: [
                Flexible(
                  child:
                  TextButton(
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
                              ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData);

                            }, currentTime: gyoshaData.startDateTime, locale: LocaleType.jp);
                      },
                      child: Text(
                        '練習開始 ${gyoshaData.startDateTime.month}/${gyoshaData.startDateTime.day} ${gyoshaData.startDateTime.hour}:${gyoshaData.startDateTime.minute}',
                      )
                  ),
                ),
                const Text("-"),
                Flexible(
                  child:
                  TextButton(
                      onPressed: () {
                        DatePicker.showDateTimePicker(context,
                            showTitleActions: true,
                            minTime: gyoshaData.startDateTime,
                            maxTime: DateTime(2100, 5, 1), onChanged: (date) {
                            }, onConfirm: (date) {
                              gyoshaData.finishDateTime = date;
                              ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData);

                            }, currentTime: gyoshaData.finishDateTime, locale: LocaleType.jp);
                      },
                      child: Text('練習終了 ${gyoshaData.finishDateTime.month.toString().padLeft(2,'0')}/${gyoshaData.finishDateTime.day.toString().padLeft(2,'0')} ${gyoshaData.finishDateTime.hour.toString().padLeft(2,'0')}:${gyoshaData.finishDateTime.minute.toString().padLeft(2,'0')} ')
                  ),
                ),
                Flexible(
                  child: Text('${editingGyoshaData.renshuHour}時間${editingGyoshaData.renshuMinutes}分'),
                )
              ],
            ),
            Row(
              children: [
                const Text("参加人数"),
                Text('${editingGyoshaData.sankashaNum}'),
                const Text("参加者名"),
                Flexible(child: Wrap(
                    children:
                    [
                      Text(editingGyoshaData.sankashaList.map<String>((SankashaData value) => value.sankashaName).join(', '),
                          overflow: TextOverflow.ellipsis),
                    ]
                ),),

                TextButton(
                  child: const Text('編集'),
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context){
                          return const SankashaEditPage();
                        })
                    );
                  },
                ),
              ],
            ),

          ]
      ),
    );
  }
}