import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class UserData{
  final String userName;
  UserData({required this.userName});
  UserData copyWith({String? userName}){
    return UserData(userName: userName??this.userName);
  }
}

class UserDatasNotifier extends StateNotifier<UserData> {
  UserDatasNotifier() : super(UserData(userName: "あなた",),){
      loadName();
  }

  void changeName(String userName)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userName', userName);
    state = state.copyWith(userName: userName);
  }

  void loadName()async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userName = prefs.getString('userName')??"あなた";
    state = state.copyWith(userName: userName);
  }

}