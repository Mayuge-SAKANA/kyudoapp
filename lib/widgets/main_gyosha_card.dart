import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:configurable_expansion_tile_null_safety/configurable_expansion_tile_null_safety.dart';

import '../data/control_data.dart';
import '../data/data_define.dart';
import '../data/data_gyosha_object.dart';
import '../main.dart';
import 'edit_gyosha_page.dart';
import 'icon_asset.dart';




@immutable
class GyoshaMainDataExpansionTile extends ConsumerWidget{
  final String gyoshaID;
  const GyoshaMainDataExpansionTile(this.gyoshaID, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    GyoshaEditManageClass gyoshaEditManage = ref.watch(gyoshaDatasProvider);
    List<GyoshaDataObj> gyoshaDataList = gyoshaEditManage.gyoshaDataList;
    var gyoshaData = gyoshaDataList.where((element) => element.gyoshaID==gyoshaID).toList()[0];

    void _moveToEditPage(){
      ref.read(gyoshaDatasProvider.notifier).setEditingGyoshaData(gyoshaID);
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context){
            return const GyoshaEditPage();
          })
      );
    }
    void _deleteSelectedGyoshaData(){
      ref.read(gyoshaDatasProvider.notifier).removeGyoshaData(gyoshaData.gyoshaID);
    }
    return ConfigurableExpansionTile(

      header: SizedBox(
          height: MediaQuery.of(context).size.height*0.15,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(5),
                border:Border.all(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  width: 2,
                ),
              boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 1,
                    //offset: Offset(0, 7), // changes position of shadow
                ),
              ],
            ),
             child: MainGyoshaCardHeaderContents(gyoshaData),
          ),),
      ),
      /*
       subtitle: Row(
        children: [
          Text(_getTekichuResultString(gyoshaData),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
              color: Theme.of(context).primaryColor,
            ),
          ),
          Text(_getRenshuTime(gyoshaData),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
      leading: SizedBox(
        child: DateTimeLeading(gyoshaData.gyoshaData.startDateTime,gyoshaData.gyoshaData.finishDateTime),
      ),
      * */


      children: [
        Column(
          children: [
            GyoshaDataScoreTable(gyoshaData),
            MainGyoshaCardButtonBar(_moveToEditPage,_deleteSelectedGyoshaData),
          ],
        ),

      ],
    );
  }
}

class MainGyoshaCardHeaderContents extends StatelessWidget{
  final GyoshaDataObj gyoshaDataObj;
  const MainGyoshaCardHeaderContents(this.gyoshaDataObj,{Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context){
    DateTime startDateTime = gyoshaDataObj.gyoshaData.startDateTime;
    DateTime finishDateTime = gyoshaDataObj.gyoshaData.finishDateTime;
    return LayoutBuilder(builder: (ctx, constraint){
      return Row(
        children: [
          SizedBox(
            height: constraint.maxHeight,
            width: constraint.maxWidth*0.25,
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,

              ),
              child: DateTimeLeading(startDateTime,finishDateTime),
            ),
          ),
          SizedBox(
            height: constraint.maxHeight,
            width: constraint.maxWidth*0.75,
            child: Center(child: Text(gyoshaDataObj.gyoshaData.gyoshaName),),
          )

        ],
      );


    });
  }
}

class MainGyoshaCardButtonBar extends StatelessWidget{
  final VoidCallback _moveToEditPage;
  final VoidCallback _deleteSelectedGyoshaData;
  const MainGyoshaCardButtonBar(this._moveToEditPage,this._deleteSelectedGyoshaData,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    );
    return ButtonBar(
      alignment: MainAxisAlignment.spaceAround,
      buttonHeight: 52.0,
      buttonMinWidth: 90.0,
      children: <Widget>[
        TextButton(
          style: flatButtonStyle,
          onPressed: () {_deleteSelectedGyoshaData();},
          child: Column(
            children: const <Widget>[
              Icon(Icons.delete),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2.0),
              ),
              Text('削除'),
            ],
          ),
        ),
        TextButton(
          style: flatButtonStyle,
          onPressed: () {_moveToEditPage();},
          child: Column(
            children: const <Widget>[
              Icon(Icons.edit),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2.0),
              ),
              Text('編集'),
            ],
          ),
        ),
      ],
    );
  }

  }


class DateTimeLeading extends StatelessWidget{
  final DateTime startDateTime;
  final DateTime finishDateTime;
  const DateTimeLeading(this.startDateTime,this.finishDateTime, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return LayoutBuilder(builder: (ctx, constraint){
      return Center(
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(startDateTime.year.toString().padLeft(4),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                fontSize: constraint.maxWidth*0.13,
              ),
            ),
            FittedBox(
              child: Text(startDateTime.month.toString().padLeft(2)+"/"+startDateTime.day.toString().padLeft(2),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: constraint.maxWidth*0.3,
                ),
              ),
            ),

            Text(startDateTime.hour.toString().padLeft(2,'0')+":"+startDateTime.minute.toString().padLeft(2,'0')+
                "-"+finishDateTime.hour.toString().padLeft(2,'0')+":"+finishDateTime.minute.toString().padLeft(2,'0'),
                style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                fontSize: constraint.maxWidth*0.13,
                ),
            )
          ],
        ),
      );
    });


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

