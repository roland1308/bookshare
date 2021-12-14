
import 'dart:convert';
import 'package:book_share/controllers/system_controller.dart';
import 'package:book_share/models/chat_details_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

String kBaseUrl =
    "https://us-central1-cifoflutter-982a7.cloudfunctions.net/app";
Uri kFirebaseUri = Uri.parse("https://fcm.googleapis.com/fcm/send");

class ChatRepository {

  final SystemController systemCtrl = Get.find<SystemController>();

  Future<Map<String, dynamic>> sendFirebaseMsg(Map<String, dynamic> newChat) async {
    try {
      var key = dotenv.env['firebaseMessagingKey'] ?? '';
      var headers = {"Content-Type":"application/json","Authorization": key};
      var body = json.encode(newChat);
      http.Response firebaseResponse = await http.post(kFirebaseUri, body:body, headers: headers);
      if (firebaseResponse.statusCode == 200 ) {
        return ({"success": true});
      } else {
        return ({"success": false, "message": "An error occurred!"});
      }
    } catch (e) {
      return ({"success": false, "message": e.toString()});
    }
  }

  Future<Map<String, dynamic>> createChat(String secondUser) async {
    var uri = Uri.parse("$kBaseUrl/api/chat/$secondUser");
    var token = systemCtrl.token.value;
    var headers = {"Authorization": token};
    try {
      http.Response response = await http.post(uri, headers: headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {

        return ({"success": true});
      } else {
        return ({"success": false, "message": "An error occurred, please retry"});
      }
    } catch (e) {
      return ({"success": false, "message": e.toString()});
    }
  }

  Future<Map<String, dynamic>> getMyChats() async {
    var uri = Uri.parse("$kBaseUrl/api/chat");
    var token = systemCtrl.token.value;
    var headers = {"Authorization": token};
    try {
      http.Response response = await http.get(uri, headers: headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        List<ChatDetails> allMyChats = listChatsFromJson(response.body);

        return ({"success": true, "listOfChats": allMyChats});
      } else {
        return ({"success": false, "message": "An error occurred, please retry"});
      }
    } catch (e) {
      return ({"success": false, "message": e.toString()});
    }
  }

  Future<Map<String, dynamic>> sendMsg(String chatId, String message) async {
    var uri = Uri.parse("$kBaseUrl/api/chat/add/$chatId");
    var token = systemCtrl.token.value;
    var headers = {"Authorization": token};
    var body = {"message": message};
    try {
      http.Response response = await http.post(uri, headers: headers, body: body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ({"success": true});
      } else {
        return ({"success": false, "message": "An error occurred, please retry"});
      }
    } catch (e) {
      return ({"success": false, "message": e.toString()});
    }
  }

}