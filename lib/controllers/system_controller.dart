import 'package:get/get.dart';

class SystemController extends GetxController {

  var isLogged = false.obs;
  var token = "".obs;
  var unreadMsgs = 0.obs;

  void setIsLogged(value){
    isLogged.value = value;
  }

  void setToken(value){
    token.value = value;
  }

  void addUnreadMsgs(){
    unreadMsgs.value++;
  }

}