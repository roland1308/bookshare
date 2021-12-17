import 'package:book_share/components/grid_view_books.dart';
import 'package:book_share/controllers/system_controller.dart';
import 'package:book_share/controllers/user_controller.dart';
import 'package:book_share/database/chat_repository.dart';
import 'package:book_share/database/user_repository.dart';
import 'package:book_share/localizations/i18n.dart';
import 'package:book_share/models/user_details_model.dart';
import 'package:book_share/services/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchUsers extends StatefulWidget {
  const SearchUsers({Key? key}) : super(key: key);

  @override
  State<SearchUsers> createState() => _SearchUsersState();
}

class _SearchUsersState extends State<SearchUsers> {
  final UserController userCtrl = Get.find<UserController>();
  final SystemController systemCtrl = Get.find<SystemController>();

  String filterText = "";
  List<UserDetails> allUsers = [];
  List<Book> allUsersBooks = [];
  final TextEditingController searchTitleController = TextEditingController();
  String searchTitle = "";
  bool isLoading = true;

  Future<List<UserDetails>> getAllUsers() async {
    Map<String, dynamic> res = await UserRepository()
        .getAllUsersDetails(userCtrl.currentUser.value.userId);
    if (res['success']) {
      allUsers = res["listOfUsers"];
    } else {
      Get.defaultDialog(content: Text(res["message"]));
    }
    return allUsers;
  }

  void getAllUsersBooks() async {
    List<UserDetails> allUsers = await getAllUsers();
    for (var element in allUsers) {
      if (element.books != null) {
        allUsersBooks.addAll(element.books!.toList());
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    getAllUsersBooks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Search other user's books".i18n),
      ),
      body: Container(
        decoration: backImageDecoration(),
        child: Align(
          child: Container(
              decoration: backTransparentDecoration(),
              padding: const EdgeInsets.all(20),
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.95,
              child: Column(
                children: [
                  TextField(
                    decoration:
                    InputDecoration(hintText: "Filter by title".i18n),
                    onChanged: (value) =>
                        setState(() {
                          searchTitle = value;
                        }),
                    controller: searchTitleController,
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                      child: allUsersBooks.isNotEmpty
                          ? GridViewBooks(
                        listToShow: allUsersBooks
                            .where((element) =>
                            element.title.contains(searchTitle))
                            .toList(),
                        callBack1: (Book book) => createChat(book),
                        icon1: const Icon(Icons.connect_without_contact),
                        color1: Colors.green,
                      )
                          : isLoading
                          ? const Center(
                        child: SizedBox(
                            height: 30,
                            width: 30,
                            child: CircularProgressIndicator()),
                      )
                          : Center(child: Text("No results.".i18n)))
                ],
              )),
        ),
      ),
    );
  }

  createChat(Book book) async {
    Map<String, dynamic> recipientDetailsResponse = await UserRepository()
        .getUserDetailsById(book.owner);
    print(recipientDetailsResponse["message"]);
    if (recipientDetailsResponse["success"]) {
      String recipient = recipientDetailsResponse["userDetails"].fcmToken;
      String body = "Hello! I'm interested in your book: ${book.title}".i18n;
      Map<String, dynamic> firebaseResponse =
      await ChatRepository().sendFirebaseMsg({
        "to": recipient,
        "notification": {"body": body}
      });
      if (firebaseResponse["success"]) {
        Map<String, dynamic> chatCreationResponse =
        await ChatRepository().createChatTable(book.owner);
        if (chatCreationResponse["success"]) {
          String chatId = chatCreationResponse["chat_id"];
          String token = systemCtrl.token.value;
          String msg = body;
          print(chatId);
          Map<String, dynamic> chatMsgResponse =
          await ChatRepository().sendMsg(token, chatId, msg);
          if (chatMsgResponse["success"]) {
            Get.snackbar("Great!", "Chat request has been sent.".i18n);
          } else {
            print(chatMsgResponse["message"]);

            return ({
              "success": false,
              "message": "An error occurred, please retry"
            });
          }
        } else {
          return ({
            "success": false,
            "message": "An error occurred, please retry"
          });
        }
      } else {
        return ({
          "success": false,
          "message": "An error occurred, please retry"
        });
      }
    } else {
      return ({
        "success": false,
        "message": "An error occurred, please retry"
      });
    }
  }
}