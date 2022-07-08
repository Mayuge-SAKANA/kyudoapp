import 'package:flutter/material.dart';
import 'package:kyodoapp/data/control_appuserdata.dart';
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

final userDatasProvider = StateNotifierProvider<UserDatasNotifier, UserData>((ref) {
  return UserDatasNotifier();
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
      theme: ref.watch(userDatasProvider).themeData,
      debugShowCheckedModeBanner: false,
      home: const MainView(),
    );
  }
}








