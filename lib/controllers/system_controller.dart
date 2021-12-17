import 'package:book_share/models/chat_details_model.dart';
import 'package:get/get.dart';

class SystemController extends GetxController {

  var isLogged = false.obs;
  var token = "".obs;
  var unreadMsgs = 0.obs;
  var activeChatMsgs = <Message>[].obs;
  var activeChatId = "".obs;

  void setIsLogged(value){
    isLogged.value = value;
  }

  void setToken(value){
    token.value = value;
  }

  // void addUnreadMsgs(){
  //   unreadMsgs.value++;
  // }

  void setActiveChatsMsgs(value){
    activeChatMsgs.value = value;
  }

  void setActiveChatId(value){
    activeChatId.value = value;
  }

  addMsgToChat(Message newMessage) {
    activeChatMsgs.add(newMessage);
  }

}