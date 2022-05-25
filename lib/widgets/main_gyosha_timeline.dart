import 'package:flutter/material.dart';
import '../main.dart';
import '../data/control_data.dart';
import '../data/data_define.dart';
import '../data/data_gyosha_object.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'main_gyosha_card.dart';

class MainView extends ConsumerWidget {
  const MainView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context,WidgetRef ref){
    GyoshaEditManageClass gyoshaEditManage = ref.watch(gyoshaDatasProvider);
    List<GyoshaDataObj> gyoshaDataList = gyoshaEditManage.gyoshaDataList;
    var _scrollController = ScrollController();

    void _createNewGyoshaData(){
      DateTime startTime = DateTime.now();
      String initialGyoshaName = "今日の行射";
      var gyoshaData = GyoshaDataObj("太刀魚魚",initialGyoshaName,GyoshaType.renshu,startTime,startTime);
      gyoshaData.addTachi();

      ref.read(gyoshaDatasProvider.notifier).addGyoshaData(gyoshaData);
    }

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
      body: ListView.builder(
        shrinkWrap: true,
        reverse: true,
        controller: _scrollController,
        itemCount: gyoshaDataList.length,
        itemBuilder:(context, index) {
          return GyoshaCard(gyoshaDataList[index].gyoshaID);
        }
      ),

      floatingActionButton: GyoshaViewFloatingActionButton(_createNewGyoshaData,_scrollController),
      drawer: const DrawerMenu(),
    );
  }
}

@immutable
class GyoshaViewFloatingActionButton extends StatelessWidget{
  final VoidCallback createNewGyoshaData;
  final ScrollController _scrollController;
  const GyoshaViewFloatingActionButton(this.createNewGyoshaData,this._scrollController, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context){
    return FloatingActionButton(
      onPressed: () {
        createNewGyoshaData();
        _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.linear,
        );
      },
      child: const Icon(Icons.add),
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


