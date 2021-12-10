import 'package:book_share/components/animated_floating_buttons.dart';
import 'package:book_share/components/grid_view_books.dart';
import 'package:book_share/controllers/system_controller.dart';
import 'package:book_share/controllers/user_controller.dart';
import 'package:book_share/database/book_repository.dart';
import 'package:book_share/models/user_details_model.dart';
import 'package:book_share/pages/edit_book_page.dart';
import 'package:book_share/services/helpers.dart';
import 'package:book_share/services/shared_prefs_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyLibraryPage extends StatelessWidget {
  MyLibraryPage({Key? key}) : super(key: key);

  final UserController userCtrl = Get.find<UserController>();
  final SystemController systemCtrl = Get.find<SystemController>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => isExitDesired(context),
      child: Scaffold(
        floatingActionButton: const AnimatedFloatingButtons(),
        //),
        appBar: AppBar(
          centerTitle: true,
          title: const Text("My Library"),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
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
                  Obx(
                    () => Expanded(
                      child: userCtrl.currentUser.value.books != null &&
                              userCtrl.currentUser.value.books!.isNotEmpty
                          ? GridViewBooks(
                              listToShow: userCtrl.currentUser.value.books!,
                              callBack1: (Book book) => editBook(book, context),
                              icon1: const Icon(Icons.edit),
                              color1: Colors.green,
                              callBack2: (Book book) =>
                                  removeBookFromMyList(book, context),
                              icon2: const Icon(Icons.delete_forever),
                              color2: Colors.red,
                            )
                          : const Center(
                              child: Text(
                                  "No books added in your personal library."),
                            ),
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
