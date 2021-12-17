import 'dart:convert';

import 'package:book_share/components/animated_floating_buttons.dart';
import 'package:book_share/components/grid_view_books.dart';
import 'package:book_share/controllers/system_controller.dart';
import 'package:book_share/controllers/user_controller.dart';
import 'package:book_share/database/book_repository.dart';
import 'package:book_share/database/chat_repository.dart';
import 'package:book_share/localizations/i18n.dart';
import 'package:book_share/models/chat_details_model.dart';
import 'package:book_share/services/notification.dart';
import 'package:book_share/models/user_details_model.dart';
import 'package:book_share/pages/chats_list.dart';
import 'package:book_share/pages/edit_book_page.dart';
import 'package:book_share/services/helpers.dart';
import 'package:book_share/services/shared_prefs_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyLibraryPage extends StatefulWidget {
  const MyLibraryPage({Key? key}) : super(key: key);

  @override
  State<MyLibraryPage> createState() => _MyLibraryPageState();
}

class _MyLibraryPageState extends State<MyLibraryPage> {
  final UserController userCtrl = Get.find<UserController>();
  final SystemController systemCtrl = Get.find<SystemController>();

  @override
  void initState() {
    final firebaseMessaging = FCM();
    firebaseMessaging.setNotifications();

    firebaseMessaging.streamCtlr.stream.listen(_changeData);
    firebaseMessaging.bodyCtlr.stream.listen(_changeBody);
    //firebaseMessaging.titleCtlr.stream.listen(_changeTitle);

    // For handling notification when the app is in background
    // but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _changeTitle(message.notification?.title ?? '');
      _changeBody(message.notification?.body ?? '');
    });

    super.initState();
  }

  @override
  void dispose() {
    final firebaseMessaging = FCM();
    firebaseMessaging.dispose();
    super.dispose();
  }

  _changeData(String msg) async {
    print("RECEIVED DATA: $msg");
    Map<String, dynamic> decoded = json.decode(msg);
    print("DECODED ${decoded}");
    decoded["id"] = int.parse(decoded["id"]);
    decoded["datetime"] = int.parse(decoded["datetime"]);
    Message messageReceived = Message.fromJson(decoded);
    print(decoded["sendertoken"]);
    Map<String, dynamic> chatMsgResponse = await ChatRepository().sendMsg(
        decoded["sendertoken"],
        systemCtrl.activeChatId.value,
        messageReceived.message);
    if (chatMsgResponse["success"]) {
      systemCtrl.addMsgToChat(Message(
          user: messageReceived.user,
          message: messageReceived.message,
          id: systemCtrl.activeChatMsgs.length,
          datetime: messageReceived.datetime,
          sendertoken: messageReceived.sendertoken
      ));
    } else {
      print(chatMsgResponse["message"]);
    }
  }

  _changeBody(String msg) {
    print("Received Body");
    systemCtrl.unreadMsgs.value++;
  }

  _changeTitle(String msg) {
    print("Received Title");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => isExitDesired(context),
      child: Scaffold(
        floatingActionButton: const AnimatedFloatingButtons(),
        //),
        appBar: AppBar(
          leading: Obx(() => Center(
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChatsList(),
                    ),
                  ),
                  child: Stack(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.message_outlined,
                          size: 30,
                        ),
                      ),
                      if (systemCtrl.unreadMsgs.value > 0)
                        Positioned(
                          right: 0,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.red,
                            child: Text(
                              systemCtrl.unreadMsgs.value.toString(),
                              style: TextStyle(
                                  fontSize: systemCtrl.unreadMsgs.value
                                              .toString()
                                              .length <
                                          3
                                      ? 14
                                      : 10),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              )),
          centerTitle: true,
          title: Text("My Library".i18n),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                print("PRESSED");
                clearPrefs();
                systemCtrl.setIsLogged(false);
              },
            )
          ],
        ),
        body: Container(
          decoration: backImageDecoration(),
          child: Align(
            child: Container(
              decoration: backTransparentDecoration(),
              padding: const EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width * 0.95,
              child: Column(
                children: [
                  Expanded(
                    child: userCtrl.currentUser.value.books != null &&
                            userCtrl.currentUser.value.books!.isNotEmpty
                        ? Obx(
                            () => GridViewBooks(
                              listToShow: userCtrl.currentUser.value.books!,
                              callBack1: (Book book) => editBook(book, context),
                              icon1: const Icon(Icons.edit),
                              color1: Colors.green,
                              callBack2: (Book book) =>
                                  removeBookFromMyList(book, context),
                              icon2: const Icon(Icons.delete_forever),
                              color2: Colors.red,
                            ),
                          )
                        : Center(
                            child: Text(
                                "No books added in your personal library."
                                    .i18n),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  editBook(Book book, context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditBook(book),
      ),
    );
  }

  removeBookFromMyList(Book book, context) async {
    Get.defaultDialog(
      barrierDismissible: false,
      title: "Removing ${book.title} from your personal library",
      content: const CircularProgressIndicator(),
    );
    Map<String, dynamic> res =
        await BookRepository().removeBookFromMyList(book.code);
    if (res["success"]) {
      Get.snackbar("Great!", res["message"]);
      userCtrl.removeLibraryBook(book.code);
    } else {
      Get.snackbar("Oh no!", res["message"]);
    }
    Navigator.pop(context);
  }
}
