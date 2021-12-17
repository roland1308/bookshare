import 'dart:convert';

import 'package:book_share/controllers/system_controller.dart';
import 'package:book_share/controllers/user_controller.dart';
import 'package:book_share/database/chat_repository.dart';
import 'package:book_share/database/user_repository.dart';
import 'package:book_share/localizations/i18n.dart';
import 'package:book_share/models/chat_details_model.dart';
import 'package:book_share/models/user_details_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatPage extends StatefulWidget {
  const ChatPage(
      {Key? key,
      required this.msgs,
      required this.secondUserEmail,
      required this.secondUserId,
      required this.chatId})
      : super(key: key);

  final List<Message> msgs;
  final String secondUserEmail;
  final String secondUserId;
  final String chatId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool _isSendingMsg = false;

  final UserController userCtrl = Get.find<UserController>();
  final SystemController systemCtrl = Get.find<SystemController>();

  final ScrollController scrollController = ScrollController();
  final TextEditingController msgController = TextEditingController();

  String secondUserFCM = "";

  @override
  void initState() {
    getSecondFCM(widget.secondUserId);
    systemCtrl.setActiveChatsMsgs(widget.msgs);
    systemCtrl.setActiveChatId(widget.chatId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.secondUserEmail),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Obx(
                () => ListView(
                  controller: scrollController,
                  children: createMsgWidgets(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 5),
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
                  onTap:
                      _isSendingMsg ? () {} : () => sendMsg(msgController.text),
                  child: CircleAvatar(
                    child: _isSendingMsg
                        ? const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: CircularProgressIndicator(
                              color: Colors.red,
                            ),
                          )
                        : const Icon(
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
    for (Message msg in systemCtrl.activeChatMsgs) {
      bool isSending = msg.user == userCtrl.currentUser.value.email;
      bool isContinue = msg.user == prevUser;
      msgWidgets.add(Align(
          alignment: isSending ? Alignment.topRight : Alignment.topLeft,
          child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              margin: isContinue
                  ? const EdgeInsets.only(top: 2)
                  : const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                  color: isSending ? Colors.green[300] : Colors.grey[300],
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              child: Text(msg.message))));
      prevUser = msg.user;
    }
    if (scrollController.hasClients) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent + 64);
    }
    return msgWidgets;
  }

  Future<void> sendMsg(String msg) async {
    if (msg != "") {
      /*setState(() {
        _isSendingMsg = true;
      });*/
      Map<String, dynamic> chatMsgResponse = await ChatRepository()
          .sendMsg(systemCtrl.token.value, widget.chatId, msg);
      if (chatMsgResponse["success"]) {
        Message newMessage = Message(
            user: userCtrl.currentUser.value.email,
            message: msg,
            id: systemCtrl.activeChatMsgs.length,
            datetime: 5,
            sendertoken: systemCtrl.token.value);
        systemCtrl.addMsgToChat(newMessage);
        msgController.clear();
        print("Sender token: ${newMessage.sendertoken}");
        print("Second fcm: $secondUserFCM");
        String recipient = secondUserFCM;
        String body = newMessage.message;
        Map<String, dynamic> firebaseResponse =
            await ChatRepository().sendFirebaseMsg({
          "to": recipient,
          "notification": {"body": body},
          "data": newMessage
        });
        if (firebaseResponse["success"]) {
          print("Great! Chat message has been sent.".i18n);
        } else {
          print(firebaseResponse["message"]);
        }

        /*setState(() {
          _isSendingMsg = false;
        });*/
      }
    }
    //scrollController.jumpTo(scrollController.position.maxScrollExtent + 34);
  }

  Future<void> getSecondFCM(String secondUserId) async {
    var secondUserResponse =
        await UserRepository().getUserDetailsById(secondUserId);
    if (secondUserResponse["success"]) {
      UserDetails secondUserDetails = secondUserResponse["userDetails"];
      print(secondUserResponse["userDetails"].fcmToken);
      setState(() {
        secondUserFCM = secondUserDetails.fcmToken!;
      });
    }
  }
}
