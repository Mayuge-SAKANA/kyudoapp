
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';

class UserData{
  final String userName;
  UserData({required this.userName});
  UserData copyWith({String? userName}){
    return UserData(userName: userName??this.userName);
  }
}

class UserDatasNotifier extends StateNotifier<UserData> {
  UserDatasNotifier() : super(UserData(userName: "まゆげ",),);

  void changeName(String userName){
    state = state.copyWith(userName: userName);
  }

}