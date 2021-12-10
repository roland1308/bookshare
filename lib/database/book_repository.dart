import 'dart:convert';

import 'package:book_share/controllers/system_controller.dart';
import 'package:book_share/models/user_details_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

String kBaseUrl =
    "https://us-central1-cifoflutter-982a7.cloudfunctions.net/app";

class BookRepository {
  final SystemController systemCtrl = Get.find<SystemController>();

  Future<Map<String, dynamic>> addBookToMyList(Book newBook) async {
    newBook.code = newBook.code.replaceAll('/', '_');
    var uri = Uri.parse("$kBaseUrl/api/book/add");
    var token = systemCtrl.token.value;
    var headers = {"Authorization": token};
    var body = newBook.toJson();
    try {
      http.Response response =
          await http.post(uri, body: body, headers: headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ({"success": true, "message": "Book added successfully!"});
      } else {
        return ({"success": false, "message": json.decode(response.body)['error']});
      }
    } catch (e) {
      return ({"success": false, "message": e.toString()});
    }
  }

  Future<Map<String, dynamic>> removeBookFromMyList(String bookCode) async {
    var uri = Uri.parse("$kBaseUrl/api/book/remove/$bookCode");
    var token = systemCtrl.token.value;
    var headers = {"Authorization": token};
    try {
      http.Response response =
      await http.post(uri, headers: headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ({"success": true, "message": "Book removed successfully!"});
      } else {
        return ({"success": false, "message": response.body});
      }
    } catch (e) {
      return ({"success": false, "message": e.toString()});
    }
  }

}
