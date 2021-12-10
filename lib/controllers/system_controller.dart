import 'package:get/get.dart';

class SystemController extends GetxController {

  var isLogged = false.obs;
  var token = "".obs;

  void setIsLogged(value){
    isLogged.value = value;
  }

  void setToken(value){
    token.value = value;
  }

}