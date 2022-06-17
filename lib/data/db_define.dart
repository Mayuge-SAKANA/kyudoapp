import 'data_gyosha_object.dart';
import 'data_define.dart';


abstract class RecordDB {
  Future<int> insertData(String tableName ,DataAbstClass data,{dynamic db});
  Future<void> updateData(String tableName ,String idName ,dynamic id, DataAbstClass data,{dynamic db});
  Future<List<Map<String, dynamic>>> queryDataMaps(String tableName ,String idName ,String id, {dynamic db});
  Future<void> deleteData(String tableName ,String idName ,String id, {dynamic db});
  Future<void> insertGyoshaDataObj(GyoshaDataObj gyoshaDataObj);
  Future<List<GyoshaDataObj>> getGyoshaDataObjList();
  Future<void> updateGyoshaData(GyoshaDataObj gyoshaDataObj);
  Future<void> deleteGyoshaData(GyoshaDataObj gyoshaDataObj);

}