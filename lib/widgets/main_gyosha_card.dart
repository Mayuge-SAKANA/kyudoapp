import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/data_view_model.dart';
import '../data/data_define.dart';
import '../data/data_gyosha_define.dart';
import '../main.dart';
import 'edit_gyosha_page.dart';
import 'icon_asset.dart';

@immutable
class GyoshaCard extends ConsumerWidget{
  final int index;
  const GyoshaCard(this.index,{Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref){
    return Card(
      child: Column(
        children: [
          GestureDetector(
            onTap: () async {
              ref.read(gyoshaDatasProvider.notifier).setEditingGyoshaData(index);
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context){
                    return const GyoshaEditPage();
                  })
              );
            },
            child:
            GyoshaMainDataRow(index),
          ),
          GyoshaDetailExpansionTile(index),
        ],
      ),
    );
  }
}

@immutable
class GyoshaMainDataRow extends ConsumerWidget{
  final int index;
  const GyoshaMainDataRow(this.index, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref){
    GyoshaEditManageClass gyoshaEditManage = ref.watch(gyoshaDatasProvider);
    List<GyoshaData> gyoshaDataList = gyoshaEditManage.gyoshaDataList;
    var gyoshaData = gyoshaDataList[index];
    return Row(
      children: [
        SizedBox(
          width: 100.0,
          height: 70.0,
          child:Center(
            child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(gyoshaData.startDateTime.year.toString().padLeft(4)),
                Text(gyoshaData.startDateTime.month.toString().padLeft(2)+"/"+gyoshaData.startDateTime.day.toString().padLeft(2),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Text(gyoshaData.startDateTime.hour.toString().padLeft(2,'0')+":"+gyoshaData.startDateTime.minute.toString().padLeft(2,'0')+
                    "-"+gyoshaData.finishDateTime.hour.toString().padLeft(2,'0')+":"+gyoshaData.finishDateTime.minute.toString().padLeft(2,'0')
                )
              ],
            ),
          ),
        ),

        Flexible(
          child: Wrap(
            children: [
              SizedBox(
                width: 250.0,
                child: Text(gyoshaData.gyoshaName,
                  style:  TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Theme.of(context).primaryColor,
                  ),),
              )
            ],
          ),
        ),

        PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          offset: const Offset(50,50),
          initialValue: false,
          onSelected: (isDelete){
            if(isDelete==true){
              ref.read(gyoshaDatasProvider.notifier).removeGyoshaData(index);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry>[
            const PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.delete),
                  title : Text('削除'),
                ),
                value: true
            ),
          ],
        ),
      ],
    );
  }
}

@immutable
class GyoshaDetailExpansionTile extends ConsumerWidget{
  final int index;
  const GyoshaDetailExpansionTile(this.index, {Key? key}) : super(key: key);
  String _getTekichuResultString(GyoshaData gyoshaData,){
    String tekichu = gyoshaData.totalSha != 0 ? gyoshaData.totalTekichu.toString() : "-";
    String total = gyoshaData.totalSha != 0 ? gyoshaData.totalSha.toString() : "-";
    String tekichuRate = gyoshaData.totalSha != 0 ? (100*gyoshaData.totalTekichu/gyoshaData.totalSha).toStringAsFixed(1) : "-";
    return "$tekichu本/$total本($tekichuRate%)";
  }
  String _getRenshuTime(GyoshaData gyoshaData){
    String hour = gyoshaData.renshuHour.toString();
    String minutes = (gyoshaData.renshuMinutes%60).toString();
    return '$hour時間$minutes分';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    GyoshaEditManageClass gyoshaEditManage = ref.watch(gyoshaDatasProvider);
    List<GyoshaData> gyoshaDataList = gyoshaEditManage.gyoshaDataList;
    var gyoshaData = gyoshaDataList[index];
    return ExpansionTile(
      title: Row(
        children: [
          Text(_getTekichuResultString(gyoshaData),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Theme.of(context).primaryColor,
            ),
          ),
          Text(_getRenshuTime(gyoshaData),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
      children: <Widget>[
        GyoshaDataScoreTable(gyoshaData),
      ],
    );
  }
}

class GyoshaDataScoreTable extends StatelessWidget{
  final GyoshaData gyoshaData;
  const GyoshaDataScoreTable(this.gyoshaData, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context){
    ShakaiResultDataObj shakaiData = ShakaiResultDataObj(gyoshaData);
    List<TableRow> tableRows = [];
    for (SankashaData sankashaData in gyoshaData.sankashaList){
      SankashaResultDataObj? sankashaResultData = shakaiData.sankashaResultMap[sankashaData.sankashaID];
      if(sankashaResultData==null)continue;
      List<Widget> iconList = [];
      for(ShaResultType result in sankashaResultData.resultList){
        if(shaResultMap[result]!=null) {
          iconList.add(shaResultMap[result]!);
        }
      }
      String tekichu = sankashaResultData.totalSha != 0 ? sankashaResultData.atariSha.toString() : "-";
      String total = sankashaResultData.totalSha != 0 ? sankashaResultData.totalSha.toString() : "-";
      String tekichuRate = sankashaResultData.totalSha != 0 ? (100*sankashaResultData.tekichuRate).toStringAsFixed(1) : "-";
      String data = "$tekichu本/$total本";
      String rate = "($tekichuRate%)";
      String rank = shakaiData.rankingMap[sankashaData.sankashaID].toString();
      tableRows.add(TableRow(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: Text(rank+"位"+sankashaData.sankashaName,overflow: TextOverflow.ellipsis),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: //Text(outString),
              Wrap(
                direction: Axis.horizontal,
                children: [
                  ...iconList,
                ],
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Column(children: [
                Text(data),
                Text(rate),
              ],),
            ),
          ]
      ));
    }
    return Table(
      columnWidths: const <int, TableColumnWidth>{
        0: FixedColumnWidth(80),
        1: FlexColumnWidth(),
        2: FixedColumnWidth(64),
      },
      children: [...tableRows],
    );
  }

}