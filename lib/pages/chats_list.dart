import 'package:book_share/controllers/user_controller.dart';
import 'package:book_share/database/chat_repository.dart';
import 'package:book_share/database/user_repository.dart';
import 'package:book_share/localizations/i18n.dart';
import 'package:book_share/models/chat_details_model.dart';
import 'package:book_share/models/user_details_model.dart';
import 'package:book_share/pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatsList extends StatefulWidget {
  const ChatsList({Key? key}) : super(key: key);

  @override
  State<ChatsList> createState() => _ChatsListState();
}

class _ChatsListState extends State<ChatsList> {
  final UserController userCtrl = Get.find<UserController>();
  List<ChatDetails> allChats = [];
  bool isLoading = true;

  Future<List<ChatDetails>> getAllMyChats() async {
    Map<String, dynamic> res = await ChatRepository()
        .getMyChats();
    if (res['success']) {
      allChats = res["listOfChats"];
    } else {
      Get.defaultDialog(content: Text(res["message"]));
    }
    return allChats;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Your active chats".i18n),
      ),
      body: FutureBuilder(
        future: getAllMyChats(),
        builder: (context, AsyncSnapshot<List<ChatDetails>> projectSnap) {
          if (projectSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (projectSnap.hasData) {
              //print('project snapshot data is: ${projectSnap.data}');
              return ListView.builder(
                itemCount: projectSnap.data!.length,
                itemBuilder: (context, index) {
                  ChatDetails chatDetails = projectSnap.data![index];
                  return InkWell(
                    onTap: ()=> Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(messages: chatDetails.messages, secondUser: chatDetails.populatedUsers[0].email, chatId: chatDetails.chatId,),
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        child:Text(chatDetails.populatedUsers[0].email[0].toUpperCase()),
                      ),
                      title: Text(chatDetails.populatedUsers[0].email),
                      trailing: Text(chatDetails.messages.length.toString()),
                    ),
                  );
                },
              );
            } else {
              return Center(child: Text("There are no chats".i18n));
            }
          }
        },
      ),
    );
  }
}
