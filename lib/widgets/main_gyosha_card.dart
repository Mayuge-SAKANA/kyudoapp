import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:configurable_expansion_tile_null_safety/configurable_expansion_tile_null_safety.dart';

import '../data/control_data.dart';
import '../data/data_define.dart';
import '../data/data_gyosha_object.dart';
import '../main.dart';
import 'edit_gyosha_page.dart';
import 'icon_asset.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share/share.dart';


class GyoshaMainDataExpansionTile extends ConsumerStatefulWidget{
  final String gyoshaID;
  const GyoshaMainDataExpansionTile(this.gyoshaID,{Key? key}) : super(key: key);
  @override
  _GyoshaMainDataExpansionTile createState() => _GyoshaMainDataExpansionTile();
}

class _GyoshaMainDataExpansionTile extends ConsumerState<GyoshaMainDataExpansionTile>{
  double opacityValue = 0;

  @override
  Widget build(BuildContext context) {
    String gyoshaID = widget.gyoshaID;
    GyoshaEditManageClass gyoshaEditManage = ref.watch(gyoshaDatasProvider);
    List<GyoshaDataObj> gyoshaDataList = gyoshaEditManage.gyoshaDataList;
    var gyoshaDataObj = gyoshaDataList.where((element) => element.gyoshaID==gyoshaID).toList()[0];
    void _moveToEditPage(){
      ref.read(gyoshaDatasProvider.notifier).setEditingGyoshaData(gyoshaID);
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context){
            return const GyoshaEditPage();
          })
      );
    }
    void _deleteSelectedGyoshaData(){
      ref.read(gyoshaDatasProvider.notifier).removeGyoshaData(gyoshaDataObj.gyoshaID,ref);
    }

    String _getResultString(){
      return gyoshaDataObj.shakaiResultDataObj.generateResultString(ref.watch(userDatasProvider).userName);
    }

    var svgImage = SvgPicture.asset('assets/imgs/SVG/maku.svg',
      color: Theme.of(context).colorScheme.primary.withOpacity(opacityValue),
      width: MediaQuery.of(context).size.width*0.95,
    );

    return ConfigurableExpansionTile(
      onExpansionChanged: (state){
        setState((){
          state?opacityValue = 0.6:opacityValue=0;
        });
      },
      header: SizedBox(
          height: MediaQuery.of(context).size.height*0.15,
          width: MediaQuery.of(context).size.width*0.95,
          child:
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Material(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  surfaceTintColor: Theme.of(context).colorScheme.primary,
                  elevation: Theme.of(context).cardTheme.elevation??1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  child:  Container(
                    alignment: Alignment.topCenter,
                    child: Stack(
                      children: [
                        svgImage,
                        MainGyoshaCardHeaderContents(gyoshaDataObj),
                      ],
                    ),
                    ),
                  ),
                ),
      ),

      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width*0.95,
          child: Column(
            children: [
              SizedBox.fromSize(size: Size(0, MediaQuery.of(context).size.height*0.01),),
              gyoshaDataObj.gyoshaData.memoText==null?
                const SizedBox():
                GyoshaExplainText(gyoshaDataObj.gyoshaData.memoText!),
              const Divider(),
              //SizedBox.fromSize(size: Size(0, MediaQuery.of(context).size.height*0.01),),
              GyoshaDataScoreTable(gyoshaDataObj),

              MainGyoshaCardButtonBar(_moveToEditPage,_deleteSelectedGyoshaData,_getResultString),
            ],
          ),
        ),
      ],
    );
  }
}

class GyoshaExplainText extends StatelessWidget{
  final String expText;
  const GyoshaExplainText(this.expText,{Key? key}) : super(key: key);
  @override
  Widget build( BuildContext context){
   return Container(
     alignment: Alignment.centerLeft,
     child: Text(expText),
   );
  }
}

class MainGyoshaCardHeaderContents extends StatelessWidget{
  final GyoshaDataObj gyoshaDataObj;
  const MainGyoshaCardHeaderContents(this.gyoshaDataObj,{Key? key}) : super(key: key);

  String getDateTxt(DateTime startDateTime){
    return "${startDateTime.year.toString().padLeft(4)}/${startDateTime.month.toString().padLeft(2)}/${startDateTime.day.toString().padLeft(2)}";
  }
  String getTimeTxt(DateTime startDateTime, DateTime finishDateTime){
    return startDateTime.hour.toString().padLeft(2,'0')+":"+startDateTime.minute.toString().padLeft(2,'0')+
        "-"+finishDateTime.hour.toString().padLeft(2,'0')+":"+finishDateTime.minute.toString().padLeft(2,'0');
  }
  
  

  @override
  Widget build(BuildContext context){
    DateTime startDateTime = gyoshaDataObj.gyoshaData.startDateTime;
    DateTime finishDateTime = gyoshaDataObj.gyoshaData.finishDateTime;

    int totalMinutes = gyoshaDataObj.calcGyoshaTime().inMinutes;
    String tekichuRateString = gyoshaDataObj.totalSha==0?"-":(100*gyoshaDataObj.totalTekichu/gyoshaDataObj.totalSha).toStringAsFixed(1);

    return LayoutBuilder(builder: (ctx, constraint){
      return Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: constraint.maxHeight*0.35,
                width: constraint.maxWidth,
                child:  Container(
                  alignment: Alignment.bottomCenter,
                  child: Text(getDateTxt(startDateTime)+" "+ getTimeTxt(startDateTime, finishDateTime),
                    style: TextStyle(fontSize: constraint.maxWidth*0.6/16),),),
              ),
              SizedBox(
                height: constraint.maxHeight*0.55,
                width: constraint.maxWidth,
                child:  Row(
                  children: [
                    SizedBox(
                      width: constraint.maxWidth*0.2,
                    ),
                    SizedBox(
                      width: constraint.maxWidth*0.6,
                      child: Container(
                        alignment: Alignment.center,
                        child:
                            Column(children: [
                              SizedBox(
                                height: constraint.maxHeight*0.35,
                                width: constraint.maxWidth*0.6,
                                child:  Center(child:
                                  Text(gyoshaDataObj.gyoshaData.gyoshaName,style: TextStyle(fontSize: constraint.maxWidth*0.6/16,fontWeight: FontWeight.bold),),
                                ),
                              ),
                               SizedBox(
                                height: constraint.maxHeight*0.15,
                                width: constraint.maxWidth*0.6,
                                 child: FittedBox(child: Text(
                                   gyoshaDataObj.gyoshaData.gyoshaEnKin==GyoshaEnKin.kinteki?
                                   "$tekichuRateString% ${(totalMinutes/60).floor()}時間${totalMinutes%60}分"
                                   :"${gyoshaDataObj.totalTekichu}点 ${(totalMinutes/60).floor()}時間${totalMinutes%60}分",
                                   style: TextStyle(fontSize: constraint.maxWidth*0.6/16),),
                                 ),
                              ),
                            ],),
                      ),
                    ),
                    SizedBox(
                      width: constraint.maxWidth*0.2,
                    ),
                  ],
                ),
              ),
            ],
          ),

          Container(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                SizedBox(
                  height: constraint.maxHeight*0.8,
                  width: constraint.maxWidth*0.2,
                  child: Container(
                    alignment: Alignment.center,
                    child: CircleAvatar(
                        radius: constraint.maxWidth*0.07,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(0),
                          child:
                          FittedBox(
                            child: Text(gyoshaTypeString[gyoshaDataObj.gyoshaData.gyoshaType]!.substring(0,1)),
                          ),
                        )
                    ),
                  ),
                ),
                SizedBox(
                  height: constraint.maxHeight*0.6,
                  width: constraint.maxWidth*0.6,
                ),
                SizedBox(
                  height: constraint.maxHeight*0.6,
                  width: constraint.maxWidth*0.2,
                  child: Container(
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      radius: constraint.maxWidth*0.07,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: FittedBox(
                        child: gyoshaDataObj.gyoshaData.gyoshaEnKin==GyoshaEnKin.kinteki?
                        Text("${gyoshaDataObj.totalTekichu}/${gyoshaDataObj.totalSha}")
                        :Text("${gyoshaDataObj.totalTekichu}"),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      );
    });
  }
}

class MainGyoshaCardButtonBar extends StatelessWidget{
  final VoidCallback _moveToEditPage;
  final VoidCallback _deleteSelectedGyoshaData;
  final Function _getResultString;
  const MainGyoshaCardButtonBar(this._moveToEditPage,this._deleteSelectedGyoshaData,this._getResultString,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    void myShowModalBottomSheetDelete(BuildContext context){
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('データの削除'),
            content: const Text("本当に削除しますか？"),

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
                  _deleteSelectedGyoshaData();
                  Navigator.pop(context);
                  //OKを押したあとの処理
                },
              ),
            ],
          );
        },
      );
    }

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
          onPressed: () {myShowModalBottomSheetDelete(context);},
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
          onPressed: () {

            Share.share(_getResultString());

            },
          child: Column(
            children: const <Widget>[
              Icon(Icons.share),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2.0),
              ),
              Text('共有'),
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



class GyoshaDataScoreTable extends ConsumerWidget{
  final GyoshaDataObj gyoshaDataObj;
  final int row = 10;
  const GyoshaDataScoreTable(this.gyoshaDataObj, {Key? key}) : super(key: key);

  List<Table> _getTables(GyoshaType gyoshaType,ShakaiResultDataObj shakaiData, double resultSpaceWidth, double rateSpaceWidth,
      double rankSpaceSize, double nameSpaceSize, double resultSpaceSize, double rateSpaceSize, WidgetRef ref){
    return gyoshaDataObj.sankashaList.map((sankashaData) {
      SankashaResultDataObj sankashaResultData = shakaiData.sankashaResultMap[sankashaData.sankashaID]!;

      String tekichu = sankashaResultData.totalSha != 0 ? sankashaResultData.atariSha.toString() : "-";
      String total = sankashaResultData.totalSha != 0 ? sankashaResultData.totalSha.toString() : "-";
      String tekichuRate = sankashaResultData.totalSha != 0 ? (100*sankashaResultData.tekichuRate).toStringAsFixed(1) : "-";

      String rate = "($tekichuRate%)";
      String rank = shakaiData.rankingMap[sankashaData.sankashaID].toString();

      List<Widget>resultIconsList = List.generate(sankashaResultData.resultList.length, (index){
        Widget? icon;
        if(index<sankashaResultData.resultList.length){
          icon = Icon(shaResultMap[sankashaResultData.resultList[index]]!.icon,size: 0.95 *resultSpaceWidth/row,);
        }
        return SizedBox(

          height: resultSpaceWidth/row,
          width: resultSpaceWidth/row,
          child: icon,
        );
      }).toList();

      return Table(
        columnWidths: <int, TableColumnWidth>{
          0: FixedColumnWidth(rankSpaceSize),
          1: FixedColumnWidth(nameSpaceSize),
          2: FixedColumnWidth(resultSpaceSize),
          3: FixedColumnWidth(rateSpaceSize),
        },
        children: [
            TableRow(
            children: [
                  Container(
                  alignment: Alignment.centerLeft,
                    child: (gyoshaType==GyoshaType.renshu||gyoshaType==GyoshaType.dantai)?
                        const SizedBox():
                        FittedBox(child: Text("$rank位"),),),
                  Container(
                   alignment: Alignment.centerLeft,
                   child: FittedBox(
                   child: Text(sankashaData.isAppUser==true? ref.watch(userDatasProvider).userName:sankashaData.sankashaName ,overflow: TextOverflow.ellipsis),
                  )
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                   child: //Text(outString),
                   Wrap(
                   direction: Axis.horizontal,
                   children: [
                  ...resultIconsList,
                   ],
                    ),
                  ),
                  Container(
                  //padding: EdgeInsets.symmetric(horizontal: 2),
                      alignment: Alignment.center,
                      child: gyoshaDataObj.gyoshaData.gyoshaEnKin==GyoshaEnKin.kinteki ?
                        Column(children: [
                          FittedBox(child: Text("$tekichu本/$total本")),
                          FittedBox(child: Text(rate),),
                        ]):
                        Column(children: [
                          FittedBox(child: Text("$tekichu点")),
                        ])
                          ,),

            ]
            )
        ],
      );


    }).toList();
  }

  @override
  Widget build(BuildContext context,WidgetRef ref){
    ShakaiResultDataObj shakaiData = gyoshaDataObj.shakaiResultDataObj;
    return LayoutBuilder(builder: (context, constraint){
        double rankSpaceSize = constraint.maxWidth*0.08;
        double nameSpaceSize = constraint.maxWidth*0.15;
        double resultSpaceSize = constraint.maxWidth*0.6;
        double rateSpaceSize = constraint.maxWidth*0.17;
        List<Table> tableData = _getTables(gyoshaDataObj.gyoshaData.gyoshaType,shakaiData,resultSpaceSize,rateSpaceSize,rankSpaceSize, nameSpaceSize, resultSpaceSize, rateSpaceSize,ref);
        List<Widget> viewData = [];
        for(Widget item in tableData){
          viewData.add(item);
          viewData.add(const Divider());
        }

        String dantaiResult = "";


        if(gyoshaDataObj.gyoshaData.gyoshaType==GyoshaType.dantai){
          if(gyoshaDataObj.gyoshaData.gyoshaEnKin==GyoshaEnKin.kinteki){
            dantaiResult += shakaiData.totalSha==0?"-":shakaiData.totalAtariSha.toString();
            dantaiResult += "本/";
            dantaiResult += shakaiData.totalSha==0?"-":shakaiData.totalSha.toString();
            dantaiResult += "本(";
            dantaiResult+= shakaiData.totalSha==0?"-":(100*shakaiData.totalAtariSha/shakaiData.totalSha).toStringAsFixed(1);
            dantaiResult += "%)";
          }else if(gyoshaDataObj.gyoshaData.gyoshaEnKin==GyoshaEnKin.enteki){
            dantaiResult += shakaiData.totalSha==0?"-":shakaiData.totalAtariSha.toString();
            dantaiResult += "点";
          }

        }


        return Column(
          children: [
            ...viewData,
            gyoshaDataObj.gyoshaData.gyoshaType==GyoshaType.dantai?
            Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                child:
                Text("合計$dantaiResult"),
              ),
            ):
            const SizedBox(),
          ],
        );

    });

  }

}

