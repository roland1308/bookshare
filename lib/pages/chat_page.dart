import 'package:book_share/controllers/user_controller.dart';
import 'package:book_share/database/chat_repository.dart';
import 'package:book_share/localizations/i18n.dart';
import 'package:book_share/models/chat_details_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatPage extends StatelessWidget {
  ChatPage({Key? key, required this.messages, required this.secondUser, required this.chatId})
      : super(key: key);

  final List<Message> messages;
  final String secondUser;
  final String chatId;

  final UserController userCtrl = Get.find<UserController>();
  final TextEditingController msgController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(secondUser),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ListView(
                children: createMsgWidgets(),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: 5),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Message".i18n,
                        filled: true,
                        fillColor: Colors.grey[400],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        contentPadding: const EdgeInsets.only(
                            left: 15, bottom: 0, top: 0, right: 15),
                      ),
                      controller: msgController,
                    ),
                  ),
                ),
                InkWell(
                  onTap: (){
                    ChatRepository().sendMsg(chatId, msgController.text);
                  },
                  child: const CircleAvatar(
                    child: Icon(
                      Icons.send,
                      size: 20,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  List<Widget> createMsgWidgets() {
    List<Widget> msgWidgets = [];
    String prevUser = "";
    for (Message msg in messages) {
      bool isSending = msg.user == userCtrl.currentUser.value.email;
      bool isContinue = msg.user == prevUser;
      msgWidgets.add(Align(
          alignment: isSending ? Alignment.topRight : Alignment.topLeft,
          child: Container(
              padding: const EdgeInsets.all(8),
              margin: isContinue
                  ? const EdgeInsets.only(top: 2)
                  : const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                  color: isSending ? Colors.green[300] : Colors.grey[300],
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              child: Text(msg.message))));
      prevUser = msg.user;
    }
    return msgWidgets;
  }
}
