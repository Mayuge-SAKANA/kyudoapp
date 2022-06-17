import 'package:flutter/material.dart';
import 'widgets/main_gyosha_timeline.dart';
import 'data/control_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'data/db_local.dart';


final recordDBProvider = StateNotifierProvider<DataDBNotifier, LocalRecordDB>(
    (ref){
      return DataDBNotifier("data_db.db");
    }
);


final gyoshaDatasProvider = StateNotifierProvider<GyoshaDatasNotifier, GyoshaEditManageClass>((ref) {
  return GyoshaDatasNotifier();
});


//void main() => runApp(const KyudoApp());
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]).then((_) {
    runApp(const ProviderScope(child: KyudoApp()));
  });
  }

class KyudoApp extends ConsumerWidget {
  const KyudoApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context,WidgetRef ref) {
    ref.read(gyoshaDatasProvider.notifier).loadGyoshaList(ref);
    return MaterialApp(
      title: 'Kyudo App',
      theme: ThemeData(
        colorSchemeSeed:  Color(0x00c14333),//Colors.blueGrey,
        brightness: Brightness.dark,
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'NotoSansJP',
      ),
      debugShowCheckedModeBanner: false,
      home: const MainView(),
    );
  }
}








