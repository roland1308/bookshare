import 'dart:async';
import 'dart:convert';

import 'package:book_share/database/user_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

Future<void> onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (message.data.containsKey('data')) {
    // Handle data message
    final data = message.data['data'];
  }

  if (message.data.containsKey('notification')) {
    // Handle notification message
    final notification = message.data['notification'];
  }
  // Or do other work.
}

class FCM {
  final _firebaseMessaging = FirebaseMessaging.instance;

  final streamCtlr = StreamController<String>.broadcast();
  //final titleCtlr = StreamController<String>.broadcast();
  final bodyCtlr = StreamController<String>.broadcast();

  setNotifications() {
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    FirebaseMessaging.onMessage.listen(
      (message) async {
        print(message.data);

        /* if (message.data.containsKey('data')) {
          print(message.data);*/
        streamCtlr.sink.add(json.encode(message.data));
        // }
        if (message.data.containsKey('notification')) {
          // Handle notification message
          streamCtlr.sink.add(message.data['notification']);
        }
        //titleCtlr.sink.add(message.notification!.title!);
        bodyCtlr.sink.add(message.notification!.body!);
      },
    );
    // With this token you can test it easily on your phone
    _firebaseMessaging.getToken().then((value) async {
      Map<String, dynamic> newData = {
        "lat": "0",
        "lng": "0",
        "fcmToken": value
      };
      var updatePosAndFCMResponse =
          await UserRepository().updatePositionAndFCM(newData);
      if (!updatePosAndFCMResponse["success"]) {
        Get.snackbar("Oh no!", updatePosAndFCMResponse["message"]);
      }
      print('Token: $value');
    });
    //TODO UPDATE USER
  }

  dispose() {
    streamCtlr.close();
    bodyCtlr.close();
    //titleCtlr.close();
  }
}
