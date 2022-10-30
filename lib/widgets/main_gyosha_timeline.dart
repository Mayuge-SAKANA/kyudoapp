import 'package:flutter/material.dart';
import 'package:kyodoapp/data/data_define.dart';
import '../main.dart';
import '../data/control_data.dart';
import '../data/data_gyosha_object.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'main_gyosha_card.dart';
import 'editing_profile.dart';

class MainView extends ConsumerWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    GyoshaEditManageClass gyoshaEditManage = ref.watch(gyoshaDatasProvider);

    List<GyoshaDataObj> gyoshaDataList = gyoshaEditManage.gyoshaDataList;
    var scrollController = ScrollController();
    void _createNewGyoshaData(){
      ref.read(gyoshaDatasProvider.notifier).createAndAddGyoshaData(ref);
    }


    void myShowModalBottomSheetSelectEnKin(BuildContext context){
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('新規作成'),
            content: const Text("データを作成します"),

            actions: <Widget>[

              ElevatedButton(
                child: const Text('遠的'),
                onPressed: () {
                  ref.read(gyoshaDatasProvider.notifier)
                      .createAndAddGyoshaData(
                      ref, gyoshaEnKin: GyoshaEnKin.enteki);


                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                child: const Text('近的'),
                onPressed: () {
                  ref.read(gyoshaDatasProvider.notifier).createAndAddGyoshaData(ref);
                  Navigator.pop(context);
                  //OKを押したあとの処理
                },
              ),
            ],
          );
        },
      );
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
        reverse: false,
        controller: scrollController,
        itemCount: gyoshaDataList.length+1,
        itemBuilder:(context, index) {
          return index==gyoshaDataList.length?
              SizedBox(height: MediaQuery.of(context).size.height*0.3)
              :GyoshaMainDataExpansionTile(gyoshaDataList[index].gyoshaID,key: ValueKey(gyoshaDataList[index].gyoshaID),);
        }
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          myShowModalBottomSheetSelectEnKin(context);
          scrollController.animateTo(
            scrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.linear,
          );
        },
        child: const Icon(Icons.add),
      ),
      //GyoshaViewFloatingActionButton(_createNewGyoshaData,scrollController),
      drawer: const DrawerMenu(),
    );
  }
}
/*
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
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.linear,
        );
      },
      child: const Icon(Icons.add),
    );
  }
}

 */

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(),
            child: Text("弓道アプリ"),
          ),
          ListTile(
            title: const Text("プロフィール"),
            onTap: (){
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context){
                    return  ProfileSetting();
                  })
              );
            },
          ),
          ListTile(
            title: const Text("タイムライン"),
            onTap: (){
              Navigator.pop(context);
            },
          ),
          /*
          ListTile(
            title: const Text("カレンダー"),
            onTap: (){
              Navigator.pop(context);
            },
          ),
          * */

        ],
      ),
    );
  }
}


