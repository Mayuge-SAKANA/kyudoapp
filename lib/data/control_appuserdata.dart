import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';


var _defaultColor = Color(0x00c14333);

class UserData{
  final String userName;
  final bool isDark;
  final Color color;
  final ThemeData themeData;
  UserData({required this.userName, required this.isDark, required this.color}):
  themeData = ThemeData(
    colorSchemeSeed: color,//Colors.blueGrey,
    brightness: isDark?Brightness.dark:Brightness.light,
    useMaterial3: true,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    fontFamily: 'NotoSansJP',
  );
  UserData copyWith({String? userName, ThemeData? themeData, bool? isDark,Color? color}){
    return UserData(userName: userName??this.userName, isDark: isDark??this.isDark, color:  color??this.color);
  }
}

class UserDatasNotifier extends StateNotifier<UserData> {
  UserDatasNotifier() : super(UserData(userName: "あなた",isDark: true, color: _defaultColor),){
      loadName();
      loadDark();
      loadColor();
  }

  void changeName(String userName)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userName', userName);
    state = state.copyWith(userName: userName);
  }

  void changeDark(bool isDark)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDark', isDark);
    state = state.copyWith(isDark: isDark);
  }
  void changeColor(Color color)async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('color', color.value);
    state = state.copyWith(color: color);
  }


  void loadName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userName = prefs.getString('userName')??"あなた";
    state = state.copyWith(userName: userName);
  }

  void loadDark() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDark = prefs.getBool('isDark')??true;
    state = state.copyWith(isDark: isDark);
  }

  void loadColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int value = prefs.getInt('color')??0x00c14333;

    state = state.copyWith(color: Color(value));
  }

}