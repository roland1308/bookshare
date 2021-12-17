import 'dart:convert';

import 'package:book_share/controllers/system_controller.dart';
import 'package:book_share/controllers/user_controller.dart';
import 'package:book_share/models/user_details_model.dart';
import 'package:book_share/services/shared_prefs_service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

String kBaseUrl =
    "https://us-central1-cifoflutter-982a7.cloudfunctions.net/app";

class UserRepository {
  final SystemController systemCtrl = Get.find<SystemController>();
  final UserController userCtrl = Get.find<UserController>();

  Future<Map<String, dynamic>> signUp(Map<String, dynamic> newUser) async {
    var uri = Uri.parse("$kBaseUrl/api/auth/signup");
    try {
      http.Response response = await http.post(uri, body: newUser);
      var decoded = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        Map<String, dynamic> responseUser =
            await getMyUserDetails(decoded["token"]);
        userCtrl.setCurrentUser(responseUser["user"]);
        await getMyUserDetails(decoded["token"]);
        // TODO CHECK
        return ({"success": true, "token": decoded["token"]});
      } else {
        return ({"success": false, "message": decoded["message"]});
      }
    } catch (e) {
      return ({"success": false, "message": e.toString()});
    }
  }

  Future<Map<String, dynamic>> signIn(Map<String, dynamic> user) async {
    var uri = Uri.parse("$kBaseUrl/api/auth/signin");
    try {
      http.Response response = await http.post(uri, body: user);
      var decoded = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        Map<String, dynamic> responseUser =
            await getMyUserDetails(decoded["token"]);
        userCtrl.setCurrentUser(responseUser["user"]);
        return ({"success": true, "token": decoded["token"]});
      } else {
        return ({"success": false, "message": decoded["message"]});
      }
    } catch (e) {
      return ({"success": false, "message": e.toString()});
    }
  }

  Future<Map<String, dynamic>> getMyUserDetails(String token) async {
    var uri = Uri.parse("$kBaseUrl/api/users/me");
    var headers = {"Authorization": token};
    try {
      http.Response response = await http.get(uri, headers: headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        userCtrl.setCurrentUser(userDetailsFromJson(response.body));
        return ({"success": true, "user": userDetailsFromJson(response.body)});
      } else {
        return ({
          "success": false,
          "message": "An error occurred, please retry"
        });
      }
    } catch (e) {
      return ({"success": false, "message": e.toString()});
    }
  }

  Future<Map<String, dynamic>> getAllUsersDetails(String me) async {
    var uri = Uri.parse("$kBaseUrl/api/book/users");
    var token = systemCtrl.token.value;
    var headers = {"Authorization": token};
    try {
      http.Response response = await http.get(uri, headers: headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        List<UserDetails> allWithoutMe = listUsersFromJson(response.body)
            .where((element) => element.userId != me)
            .toList();
        return ({"success": true, "listOfUsers": allWithoutMe});
      } else {
        return ({
          "success": false,
          "message": "An error occurred, please retry"
        });
      }
    } catch (e) {
      return ({"success": false, "message": e.toString()});
    }
  }

  Future<Map<String, dynamic>> updatePositionAndFCM(
      Map<String, dynamic> newData) async {
    var uri = Uri.parse("$kBaseUrl/api/updatePosition");
    var token = systemCtrl.token.value;
    var headers = {"Authorization": token};
    try {
      http.Response response =
          await http.put(uri, body: newData, headers: headers);
      var decoded = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ({"success": true});
      } else {
        return ({"success": false, "message": decoded["message"]});
      }
    } catch (e) {
      print(e);
      return ({"success": false, "message": e.toString()});
    }
  }

  Future<Map<String, dynamic>> getUserDetailsById(String userId) async {
    var uri = Uri.parse("$kBaseUrl/api/user/$userId");
    var token = systemCtrl.token.value;
    var headers = {"Authorization": token};
    try {
      http.Response response = await http.get(uri, headers: headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        UserDetails usrDetails =
            UserDetails.fromJson(json.decode(response.body));
        var ff = json.decode(response.body);
        print(ff["fcmToken"]);
        return ({"success": true, "userDetails": usrDetails});
      } else {
        return ({
          "success": false,
          "message": "An error occurred, please retry"
        });
      }
    } catch (e) {
      return ({"success": false, "message": e.toString()});
    }
  }
}
