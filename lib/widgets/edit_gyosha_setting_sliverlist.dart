import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import 'edit_sankasha_page.dart';

import '../data/data_define.dart';
import '../data/data_gyosha_define.dart';


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
    GyoshaType initType = ref.read(gyoshaDatasProvider).editingGyoshaData.gyoshaType;
    _toggleList[initType.index]=true;
  }

  @override
  Widget build(BuildContext context) {
    GyoshaData editingGyoshaData = ref.watch(gyoshaDatasProvider).editingGyoshaData;

    return SliverList(
      delegate: SliverChildListDelegate(
          [
            TextFormField(
              decoration: const InputDecoration(hintText: 'タイトルを入力'),
              controller: TextEditingController.fromValue(
                TextEditingValue(
                  text: editingGyoshaData.gyoshaName,
                  selection: TextSelection.collapsed(offset:
                  editingGyoshaData.gyoshaName.length),
                ),
              ),
              onChanged: (newValue){
                editingGyoshaData.gyoshaName = newValue;
              },
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
                //editingGyoshaData.gyoshaName =_tempTitle;
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
                      editingGyoshaData.gyoshaType = GyoshaType.values[index];
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
                              editingGyoshaData.startDateTime = date;
                              if(editingGyoshaData.finishDateTime.isBefore(editingGyoshaData.startDateTime)){
                                editingGyoshaData.finishDateTime = editingGyoshaData.startDateTime;
                              }
                              ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData);

                            }, currentTime: editingGyoshaData.startDateTime, locale: LocaleType.jp);
                      },
                      child: Text(
                        '練習開始 ${editingGyoshaData.startDateTime.month}/${editingGyoshaData.startDateTime.day} ${editingGyoshaData.startDateTime.hour}:${editingGyoshaData.startDateTime.minute}',
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
                            minTime: editingGyoshaData.startDateTime,
                            maxTime: DateTime(2100, 5, 1), onChanged: (date) {
                            }, onConfirm: (date) {
                              editingGyoshaData.finishDateTime = date;
                              ref.read(gyoshaDatasProvider.notifier).renewGyoshaData(editingGyoshaData);

                            }, currentTime: editingGyoshaData.finishDateTime, locale: LocaleType.jp);
                      },
                      child: Text('練習終了 ${editingGyoshaData.finishDateTime.month.toString().padLeft(2,'0')}/${editingGyoshaData.finishDateTime.day.toString().padLeft(2,'0')} ${editingGyoshaData.finishDateTime.hour.toString().padLeft(2,'0')}:${editingGyoshaData.finishDateTime.minute.toString().padLeft(2,'0')} ')
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