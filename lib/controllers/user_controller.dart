/*
Doc({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.language,
    required this.authorKey,
  });
*/

import 'package:book_share/models/user_details_model.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  var currentUser = UserDetails(
    userId: "userId",
    email: "email",
    createdAt: DateTime.now(),
    books: <Book>[],
  ).obs;

  setCurrentUser(UserDetails loggedUser) {
    currentUser.value = loggedUser;
  }

  addLibraryBook(Book newBook) {
    currentUser.value.books?.add(newBook);
    currentUser.refresh();
  }

  removeLibraryBook(String bookCode) {
    currentUser.value.books?.removeWhere((element) => element.code == bookCode);
    currentUser.refresh();
  }
}

// {
//     "code":"089s05",
//     "title":"El alquimista" ,
//     "coverLink":"https://....",
//     "status":"Shared",
//     "availability":0
// }
