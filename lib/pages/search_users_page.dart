import 'package:book_share/components/grid_view_books.dart';
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
              width: MediaQuery.of(context).size.width * 0.95,
              child: Column(
                children: [
                  TextField(
                    decoration:
                        InputDecoration(hintText: "Filter by title".i18n),
                    onChanged: (value) => setState(() {
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
    String recipient = "fTX2hk5bTCWQlCKS4ryCx0:APA91bF-QJbHDtJd98YabiNgmXV4bpGcsEEwfYcmPgcfOPMElatFt5mYsf21-Bhtxr6H5HXl71rpdi7QPHswx-DWydbplRQxgxlWgNtPE-zXeHiLRRvNfG2uHx_XdgTdlVsyb_8yThy-";
    String title = "Create Chat";
    String body = "Hello! I'm interested in your book: ${book.title}".i18n;
    Map<String, dynamic>firebaseResponse = await ChatRepository().sendFirebaseMsg({
      "to": recipient,
      "notification": {"title": title, "body": body}
    });
    if(firebaseResponse["success"]){

      Get.snackbar("Great!", "Chat request has been sent.".i18n);

    }

  }
}
