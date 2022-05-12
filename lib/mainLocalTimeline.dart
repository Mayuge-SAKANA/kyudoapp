import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
              GestureDetector(
                onTap: () async {
                  ref.read(gyoshaDatasProvider.notifier).setEditingGyoshaData(index);
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context){
                        return const GyoshaEditPage();
                      })
                  );
                },
                child: GyoshaCard(index),
              );
          }
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          DateTime startTime = DateTime.now();
          String initialGyoshaName = "今日の行射";
          var gyoshaData = GyoshaData("太刀魚",initialGyoshaName,GyoshaType.renshu,startTime,startTime);
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

class GyoshaCard extends ConsumerWidget{
  int index;
  GyoshaCard(this.index,{Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref){
    GyoshaEditManageClass gyoshaEditManage = ref.watch(gyoshaDatasProvider);
    List<GyoshaData> gyoshaDataList = gyoshaEditManage.gyoshaDataList;
    var gyoshaData = gyoshaDataList[index];
    return Card(
        child: Column(
          children: [
            GyoshaMainDataRow(index),
            GyoshaDetailExpansionTile(index),
          ],
        ),
    );
  }
}

class GyoshaMainDataRow extends ConsumerWidget{
  int index;
  GyoshaMainDataRow(this.index, {Key? key}) : super(key: key);
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
                Text(gyoshaData.startDateTime.hour.toString().padLeft(2,'0')+":"+gyoshaData.startDateTime.day.toString().padLeft(2,'0')+
                    "-"+gyoshaData.finishDateTime.hour.toString().padLeft(2,'0')+":"+gyoshaData.finishDateTime.day.toString().padLeft(2,'0')
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
        /*
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
        */
      ],
    );
  }
}

class GyoshaDetailExpansionTile extends ConsumerWidget{
  int index;
  GyoshaDetailExpansionTile(this.index, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    GyoshaEditManageClass gyoshaEditManage = ref.watch(gyoshaDatasProvider);
    List<GyoshaData> gyoshaDataList = gyoshaEditManage.gyoshaDataList;
    var gyoshaData = gyoshaDataList[index];
    return ExpansionTile(
      title: Row(
        children: [
          Text('${gyoshaDataList[index].countAppUserAtariTotal()}/${gyoshaDataList[index].countAppUserShaTotal()}的中',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Theme.of(context).primaryColor,
            ),
          ),
          Text('${(gyoshaDataList[index].renshuHour+gyoshaDataList[index].renshuMinutes/60).toStringAsFixed(1)}時間',
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
            child: Text('ここに結果詳細をかく',
              style: TextStyle(
              fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Theme.of(context).primaryColor,
              ),
            ),
        ),
      ],
    );
  }
}

