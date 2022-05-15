import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kyodoapp/iconAsset.dart';
import 'package:kyodoapp/main.dart';
import 'dataViewModel.dart';
import 'dataDefine.dart';
import 'gyoshaEditPage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainView extends StatelessWidget {
  const MainView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('タイムライン'),
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.calendar_month_rounded),
          ),
        ],
      ),
      body: const Center(
        child: GyoshaListView(),
      ),
      drawer: const DrawerMenu(),
    );
  }
}

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(),
            child: Text("Drawer Header"),
          ),
          ListTile(
            title: const Text("プロフィール"),
            onTap: (){
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text("タイムライン"),
            onTap: (){
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text("カレンダー"),
            onTap: (){
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class GyoshaListView extends ConsumerWidget{
  const GyoshaListView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context,WidgetRef ref) {
    GyoshaEditManageClass gyoshaEditManage = ref.watch(gyoshaDatasProvider);
    List<GyoshaData> gyoshaDataList = gyoshaEditManage.gyoshaDataList;
    var _scrollController = ScrollController();

    return Scaffold(
      body: ListView.builder(
          shrinkWrap: true,
          reverse: true,
          controller: _scrollController,
          itemCount: gyoshaDataList.length,
          itemBuilder:(context, index) {
            var gyoshaData = gyoshaDataList[index];
            return
             GyoshaCard(index);

          }
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          DateTime startTime = DateTime.now();
          String initialGyoshaName = "今日の行射";
          var gyoshaData = GyoshaData("太刀魚魚",initialGyoshaName,GyoshaType.renshu,startTime,startTime);
          gyoshaData.addTachi();
          ref.read(gyoshaDatasProvider.notifier).addGyoshaData(gyoshaData);

          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.linear,
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

@immutable
class GyoshaCard extends ConsumerWidget{
  final int index;
  const GyoshaCard(this.index,{Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref){
    GyoshaEditManageClass gyoshaEditManage = ref.watch(gyoshaDatasProvider);
    List<GyoshaData> gyoshaDataList = gyoshaEditManage.gyoshaDataList;
    var gyoshaData = gyoshaDataList[index];
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
                    fontSize: 30,
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
                child: Text(gyoshaDataList[index].gyoshaName,
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

class GyoshaDetailExpansionTile extends ConsumerWidget{
  int index;
  GyoshaDetailExpansionTile(this.index, {Key? key}) : super(key: key);
  Map<String, double> junniMap = {};
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
  Widget _scoreDataWidget(GyoshaData gyoshaData) {
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
        Container(
            child:
            _scoreDataWidget(gyoshaData),
            ),
      ],
    );
  }
}

