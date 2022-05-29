import 'package:flutter/material.dart';
import 'widgets/main_gyosha_timeline.dart';
import 'data/control_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final gyoshaDatasProvider = StateNotifierProvider<GyoshaDatasNotifier, GyoshaEditManageClass>((ref) {
  return GyoshaDatasNotifier();
});


//void main() => runApp(const KyudoApp());
void main() => runApp(const ProviderScope(child: KyudoApp()));

class KyudoApp extends StatelessWidget {
  const KyudoApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kyudo App',
      theme: ThemeData(
        colorSchemeSeed: const Color(0x00c14333),//Colors.blueGrey,
        brightness: Brightness.light,
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'NotoSansJP',
      ),
      debugShowCheckedModeBanner: false,
      home: const MainView(),
    );
  }
}








