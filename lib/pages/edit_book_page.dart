import 'package:book_share/components/show_book_by_tag.dart';
import 'package:book_share/controllers/user_controller.dart';
import 'package:book_share/database/book_repository.dart';
import 'package:book_share/models/user_details_model.dart';
import 'package:book_share/services/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditBook extends StatefulWidget {
  const EditBook(this.book, {Key? key}) : super(key: key);

  final Book book;

  @override
  State<EditBook> createState() => _EditBookState();
}

class _EditBookState extends State<EditBook> {
  final UserController userCtrl = Get.find<UserController>();
  TextEditingController statusController = TextEditingController();
  List<String> splittedTitle = [];
  bool _isChange = false;
  bool _isDonate = false;
  bool _isSell = false;
  bool _isWanted = false;
  bool _hasChanged = false;

  @override
  void initState() {
    splittedTitle = widget.book.title.split('(');
    statusController.text = widget.book.status;
    if (widget.book.availability[0] == '1') _isChange = true;
    if (widget.book.availability[1] == '1') _isDonate = true;
    if (widget.book.availability[2] == '1') _isSell = true;
    if (widget.book.availability[3] == '1') _isWanted = true;
    super.initState();
  }

  Future<void> updateBook() async {
    // TODO
    // As "update book" on backend doesn't work, I will remove old book
    //  and add a new one when disposing the page.
    FocusScope.of(context).unfocus();
    Map<String, dynamic> res =
        await BookRepository().removeBookFromMyList(widget.book.code);
    if (res["success"]) {
      userCtrl.removeLibraryBook(widget.book.code);
      Map<String, dynamic> res =
          await BookRepository().addBookToMyList(widget.book);

      print("New avail: ${widget.book.availability}");
      if (res["success"]) {
        userCtrl.addLibraryBook(widget.book);
        Get.snackbar("Great!", "Book updated successfully!");
      } else {
        Get.snackbar("Oh no!", "An error occurred!");
      }
    } else {
      Get.snackbar("Oh no!", "An error occurred!");
    }
    Navigator.pop(context);
  }

  void checkChanges() {
    String _newBookAvailability = "";
    _newBookAvailability += _isChange ? '1' : '0';
    _newBookAvailability += _isDonate ? '1' : '0';
    _newBookAvailability += _isSell ? '1' : '0';
    _newBookAvailability += _isWanted ? '1' : '0';
    if (widget.book.availability != _newBookAvailability ||
        widget.book.status != statusController.text) {
      widget.book.availability = _newBookAvailability;
      widget.book.status = statusController.text;
      _hasChanged = true;
    } else {
      _hasChanged = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _hasChanged
          ? FloatingActionButton(
              onPressed: () => updateBook(),
              child: Icon(Icons.save),
              backgroundColor: Colors.red)
          : null,
      appBar: AppBar(
        title: const Text("Edit your book's details"),
      ),
      body: Container(
        decoration: const BoxDecoration(
            color: Colors.transparent,
            image: DecorationImage(
              image: AssetImage("assets/images/biblioteca_web.jpg"),
              fit: BoxFit.cover,
            )),
        child: Align(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(.7),
                borderRadius: const BorderRadius.all(Radius.circular(20))),
            padding: const EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width * 0.95,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 150,
                      width: 100,
                      margin: const EdgeInsets.only(right: 10),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ShowBookByTag(
                                  title: widget.book.title,
                                  image: widget.book.coverLink),
                            ),
                          );
                        },
                        child: Hero(
                          tag: widget.book.coverLink,
                          child: Image.network(
                            widget.book.coverLink,
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            splittedTitle[0],
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          Text(
                              splittedTitle[1]
                                  .substring(0, splittedTitle[1].length - 1),
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(.5),
                                border: Border.all(
                                  color: Colors.red,
                                ),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(20))),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: CheckboxListTile(
                                        title: const Text(
                                          "Change",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        contentPadding: const EdgeInsets.all(0),
                                        value: _isChange,
                                        dense: true,
                                        onChanged: (newValue) {
                                          if (newValue != null && newValue)
                                            _isWanted = false;
                                          _isChange = newValue!;
                                          checkChanges();
                                        },
                                        controlAffinity: ListTileControlAffinity
                                            .leading, //  <-- leading Checkbox
                                      ),
                                    ),
                                    Expanded(
                                      child: CheckboxListTile(
                                        title: const Text(
                                          "Donate",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        contentPadding: EdgeInsets.all(0),
                                        value: _isDonate,
                                        dense: true,
                                        onChanged: (newValue) {
                                          if (newValue != null && newValue)
                                            _isWanted = false;
                                          _isDonate = newValue!;
                                          checkChanges();
                                        },
                                        controlAffinity: ListTileControlAffinity
                                            .leading, //  <-- leading Checkbox
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: CheckboxListTile(
                                        title: const Text(
                                          "Sell",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        contentPadding: const EdgeInsets.all(0),
                                        value: _isSell,
                                        dense: true,
                                        onChanged: (newValue) {
                                          if (newValue != null && newValue)
                                            _isWanted = false;
                                          _isSell = newValue!;
                                          checkChanges();
                                        },
                                        controlAffinity: ListTileControlAffinity
                                            .leading, //  <-- leading Checkbox
                                      ),
                                    ),
                                    Expanded(
                                      child: CheckboxListTile(
                                        title: const Text(
                                          "Wanted",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        contentPadding: const EdgeInsets.all(0),
                                        value: _isWanted,
                                        dense: true,
                                        onChanged: (newValue) {
                                          if (newValue != null && newValue) {
                                            _isChange = false;
                                            _isSell = false;
                                            _isDonate = false;
                                          }
                                          _isWanted = newValue!;
                                          checkChanges();
                                        },
                                        controlAffinity: ListTileControlAffinity
                                            .leading, //  <-- leading Checkbox
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "Book details",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.5),
                        border: Border.all(
                          color: Colors.red,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20))),
                    padding: const EdgeInsets.all(8),
                    child: SingleChildScrollView(
                        child: TextField(
                            onChanged: (text) => checkChanges(),
                            controller: statusController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: buildStatusDecoration(
                                hintText: "Type a description for your book"))),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
