import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/control_data.dart';
import '../data/data_define.dart';
import '../data/data_gyosha_object.dart';
import '../main.dart';
import 'edit_gyosha_page.dart';
import 'icon_asset.dart';


@immutable
class GyoshaCard extends ConsumerWidget{
  final String gyoshaID;
  const GyoshaCard(this.gyoshaID,{Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref){
    return Card(
      child: Column(
        children: [
          GestureDetector(
            onTap: () async {
              ref.read(gyoshaDatasProvider.notifier).setEditingGyoshaData(gyoshaID);
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context){
                    return const GyoshaEditPage();
                  })
              );
            },
            child:
            GyoshaMainDataRow(gyoshaID),
          ),
          GyoshaDetailExpansionTile(gyoshaID),
        ],
      ),
    );
  }
}

@immutable
class GyoshaMainDataRow extends ConsumerWidget{
  final String gyoshaID;
  const GyoshaMainDataRow(this.gyoshaID, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref){
    GyoshaEditManageClass gyoshaEditManage = ref.watch(gyoshaDatasProvider);
    var gyoshaData = gyoshaEditManage.gyoshaDataList.where((element) => element.gyoshaID==gyoshaID).toList()[0].gyoshaData;
    DateTime startDateTime = gyoshaData.startDateTime;
    DateTime finishDateTime = gyoshaData.finishDateTime;

    return Row(
      children: [
        SizedBox(
          width: 100.0,
          height: 70.0,
          child:Center(
            child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(startDateTime.year.toString().padLeft(4)),
                Text(startDateTime.month.toString().padLeft(2)+"/"+startDateTime.day.toString().padLeft(2),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Text(startDateTime.hour.toString().padLeft(2,'0')+":"+startDateTime.minute.toString().padLeft(2,'0')+
                    "-"+finishDateTime.hour.toString().padLeft(2,'0')+":"+finishDateTime.minute.toString().padLeft(2,'0')
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
              ref.read(gyoshaDatasProvider.notifier).removeGyoshaData(gyoshaData.gyoshaID);
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
  final String gyoshaID;
  const GyoshaDetailExpansionTile(this.gyoshaID, {Key? key}) : super(key: key);
  String _getTekichuResultString(GyoshaDataObj gyoshaDataObj,){
    String tekichu = gyoshaDataObj.totalSha != 0 ? gyoshaDataObj.totalTekichu.toString() : "-";
    String total = gyoshaDataObj.totalSha != 0 ? gyoshaDataObj.totalSha.toString() : "-";
    String tekichuRate = gyoshaDataObj.totalSha != 0 ? (100*gyoshaDataObj.totalTekichu/gyoshaDataObj.totalSha).toStringAsFixed(1) : "-";
    return "$tekichu本/$total本($tekichuRate%)";
  }
  String _getRenshuTime(GyoshaDataObj gyoshaDataObj){
    String hour = gyoshaDataObj.renshuHour.toString();
    String minutes = (gyoshaDataObj.renshuMinutes%60).toString();
    return '$hour時間$minutes分';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    GyoshaEditManageClass gyoshaEditManage = ref.watch(gyoshaDatasProvider);
    List<GyoshaDataObj> gyoshaDataList = gyoshaEditManage.gyoshaDataList;
    var gyoshaData = gyoshaDataList.where((element) => element.gyoshaID==gyoshaID).toList()[0];
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
  final GyoshaDataObj gyoshaData;
  const GyoshaDataScoreTable(this.gyoshaData, {Key? key}) : super(key: key);

  List<TableRow> _getTableRows(shakaiData){
    return gyoshaData.sankashaList.map((sankashaData) {
      SankashaResultDataObj sankashaResultData = shakaiData.sankashaResultMap[sankashaData.sankashaID]!;
      List<Widget>iconList = sankashaResultData.resultList.map((e){return shaResultMap[e] as Widget;}).toList();
      String tekichu = sankashaResultData.totalSha != 0 ? sankashaResultData.atariSha.toString() : "-";
      String total = sankashaResultData.totalSha != 0 ? sankashaResultData.totalSha.toString() : "-";
      String tekichuRate = sankashaResultData.totalSha != 0 ? (100*sankashaResultData.tekichuRate).toStringAsFixed(1) : "-";
      String data = "$tekichu本/$total本";
      String rate = "($tekichuRate%)";
      String rank = shakaiData.rankingMap[sankashaData.sankashaID].toString();

      return TableRow(
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
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context){
    ShakaiResultDataObj shakaiData = gyoshaData.shakaiResultDataObj;
    List<TableRow> tableRows =_getTableRows(shakaiData);

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

