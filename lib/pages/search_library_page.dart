import 'package:book_share/components/grid_view_books.dart';
import 'package:book_share/components/show_book_by_tag.dart';
import 'package:book_share/controllers/user_controller.dart';
import 'package:book_share/database/book_repository.dart';
import 'package:book_share/database/database_service.dart';
import 'package:book_share/localizations/i18n.dart';
import 'package:book_share/models/book_search_model.dart';
import 'package:book_share/models/user_details_model.dart';
import 'package:book_share/services/helpers.dart';
import 'package:book_share/services/shared_prefs_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchLibrary extends StatefulWidget {
  const SearchLibrary({Key? key}) : super(key: key);

  @override
  State<SearchLibrary> createState() => _SearchLibrary();
}

class _SearchLibrary extends State<SearchLibrary> {
  final userCtrl = Get.find<UserController>();
  List<Book> listOfBooks = [];
  bool isLoading = false;
  final TextEditingController searchTitleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Search OpenLibrary.org".i18n),
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
                    controller: searchTitleController,
                  ),
                  ElevatedButton(
                    onPressed: !isLoading
                        ? () => doSearch(searchTitleController.text)
                        : () => {},
                    child: !isLoading
                        ? Text("Search".i18n)
                        : const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.red,
                            ),
                          ),
                  ),
                  Expanded(
                      child: listOfBooks.isNotEmpty
                          ? GridViewBooks(
                              listToShow: listOfBooks,
                              callBack1: (Book book) =>
                                  addBookToMyLibrary(book),
                              icon1: const Icon(Icons.add),
                              color1: Colors.green,
                            )
                          : Center(child: Text("No results.".i18n)))
                ],
              )),
        ),
      ),
    );
  }

  void doSearch(String title) async {
    setState(() {
      isLoading = true;
    });
    FocusScope.of(context).unfocus();
// Get a complex list of books (List<Doc>) from OpenLibrary (BookSearchModel)
    Map<String, dynamic> res = await OpenLibraryDB().searchTitle(title);
    if (res['success']) {
      // Transform the List<Doc> in List<Book>
      List<Doc> searchResult = res['response'];
      List<Book> searchResultAsBooks = [];
      for (Doc docFromSearch in searchResult) {
        searchResultAsBooks.add(Book(
            availability: "0000",
            code: docFromSearch.key,
            owner: userCtrl.currentUser.value.userId,
            title: docFromSearch.title +
                (docFromSearch.author != ''
                    ? ' (${docFromSearch.author})'
                    : ''),
            coverLink: docFromSearch.imageLink,
            status: "New book just added to personal library. Please personalize the description."));
      }
      listOfBooks = searchResultAsBooks;
    } else {
      Get.defaultDialog(content: Text(res["message"]));
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> addBookToMyLibrary(Book book) async {
    Get.defaultDialog(
      barrierDismissible: false,
      title: "Adding ${book.title} to your personal library",
      content: const CircularProgressIndicator(),
    );
    Map<String, dynamic> res = await BookRepository().addBookToMyList(book);
    if (res["success"]) {
      Get.snackbar("Great!", res["message"]);
      userCtrl.addLibraryBook(book);
    } else {
      Get.snackbar("Oh no!", res["message"]);
    }
    Navigator.pop(context);
  }
}
