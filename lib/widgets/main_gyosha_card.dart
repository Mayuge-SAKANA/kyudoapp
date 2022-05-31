import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:configurable_expansion_tile_null_safety/configurable_expansion_tile_null_safety.dart';

import '../data/control_data.dart';
import '../data/data_define.dart';
import '../data/data_gyosha_object.dart';
import '../main.dart';
import 'edit_gyosha_page.dart';
import 'icon_asset.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';



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

    var svgImage = Svg('assets/imgs/SVG/maku.svg',
      color: Theme.of(context).colorScheme.primaryContainer,
      size: const Size(1000,89),
    );

    return ConfigurableExpansionTile(


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
                  child:  Container(child: MainGyoshaCardHeaderContents(gyoshaData),
                      decoration: BoxDecoration(
                        image:  DecorationImage(
                          image: svgImage,
                          fit: BoxFit.fitWidth,
                          alignment:  Alignment.topCenter,
                        ),
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
              gyoshaData.gyoshaData.memoText==null?const SizedBox():GyoshaExplainText(gyoshaData.gyoshaData.memoText!),
              const Divider(),
              //SizedBox.fromSize(size: Size(0, MediaQuery.of(context).size.height*0.01),),
              GyoshaDataScoreTable(gyoshaData),

              MainGyoshaCardButtonBar(_moveToEditPage,_deleteSelectedGyoshaData),
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
    return startDateTime.year.toString().padLeft(4)+"/"+
        startDateTime.month.toString().padLeft(2)+"/"+startDateTime.day.toString().padLeft(2);
  }
  String getTimeTxt(DateTime startDateTime, DateTime finishDateTime){
    return startDateTime.hour.toString().padLeft(2,'0')+":"+startDateTime.minute.toString().padLeft(2,'0')+
        "-"+finishDateTime.hour.toString().padLeft(2,'0')+":"+finishDateTime.minute.toString().padLeft(2,'0');
  }



  
  @override
  Widget build(BuildContext context){
    DateTime startDateTime = gyoshaDataObj.gyoshaData.startDateTime;
    DateTime finishDateTime = gyoshaDataObj.gyoshaData.finishDateTime;
    //var s = svgImage.color
    var svgImage = Svg('assets/imgs/SVG/maku.svg',
        color: Theme.of(context).colorScheme.primaryContainer,
        size: Size(1000,121),
    );
    return LayoutBuilder(builder: (ctx, constraint){
      return Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: constraint.maxHeight*0.4,
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
                                 child: FittedBox(child: Text("-% -時間-分",style: TextStyle(fontSize: constraint.maxWidth*0.6/16),),),
                              )
                              ,
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
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Padding(
                          padding: EdgeInsets.all(0),
                          child:
                          FittedBox(
                            child: Text("練"),
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
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: FittedBox(
                        child: Text("${gyoshaDataObj.totalTekichu}/${gyoshaDataObj.totalSha}"),
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
  final int row = 10;
  const GyoshaDataScoreTable(this.gyoshaData, {Key? key}) : super(key: key);

  List<Table> _getTables(ShakaiResultDataObj shakaiData, double resultSpaceWidth, double rateSpaceWidth,
      double rankSpaceSize, double nameSpaceSize, double resultSpaceSize, double rateSpaceSize,){
    return gyoshaData.sankashaList.map((sankashaData) {
      SankashaResultDataObj sankashaResultData = shakaiData.sankashaResultMap[sankashaData.sankashaID]!;

      String tekichu = sankashaResultData.totalSha != 0 ? sankashaResultData.atariSha.toString() : "-";
      String total = sankashaResultData.totalSha != 0 ? sankashaResultData.totalSha.toString() : "-";
      String tekichuRate = sankashaResultData.totalSha != 0 ? (100*sankashaResultData.tekichuRate).toStringAsFixed(1) : "-";

      String rate = "($tekichuRate%)";
      String rank = shakaiData.rankingMap[sankashaData.sankashaID].toString();

      List<Widget>resultIconsList = List.generate(sankashaResultData.resultList.length, (index){
        Widget? icon;
        if(index<sankashaResultData.resultList.length){
          IconData i =  shaResultIcon[sankashaResultData.resultList[index]]!;
          icon = Icon(i,size: 0.95 *resultSpaceWidth/row,);
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
                    child: FittedBox(child: Text("$rank位"),),)
                  ,
                  Container(
                   alignment: Alignment.centerLeft,
                   child: FittedBox(
                   child: Text(sankashaData.sankashaName==""? "名無し":sankashaData.sankashaName ,overflow: TextOverflow.ellipsis),
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
                      child: Column(children: [
                        FittedBox(child: Text("$tekichu本/$total本")),
                        FittedBox(child: Text(rate),),
                   ],),
            ),
            ]
            )
        ],
      );


    }).toList();
  }

  @override
  Widget build(BuildContext context){
    ShakaiResultDataObj shakaiData = gyoshaData.shakaiResultDataObj;
    return LayoutBuilder(builder: (context, constraint){
        double rankSpaceSize = constraint.maxWidth*0.08;
        double nameSpaceSize = constraint.maxWidth*0.15;
        double resultSpaceSize = constraint.maxWidth*0.6;
        double rateSpaceSize = constraint.maxWidth*0.17;
        List<Table> tableData = _getTables(shakaiData,resultSpaceSize,rateSpaceSize,rankSpaceSize, nameSpaceSize, resultSpaceSize, rateSpaceSize);
        List<Widget> viewData = [];
        for(Widget item in tableData){
          viewData.add(item);
          viewData.add(Divider());
        }
      return
        Column(
          children: [
            ...viewData,


          ],
        );

    });

  }

}

