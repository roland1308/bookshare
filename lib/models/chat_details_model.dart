// To parse this JSON data, do
//
//     final chatDetails = chatDetailsFromJson(jsonString);

import 'dart:convert';

import 'package:book_share/models/user_details_model.dart';

ChatDetails chatDetailsFromJson(String str) => ChatDetails.fromJson(json.decode(str));
List<ChatDetails> listChatsFromJson(String str) => List<ChatDetails>.from(json.decode(str).map((x) => ChatDetails.fromJson(x)));

class ChatDetails {
  ChatDetails({
    required this.messages,
    required this.read,
    required this.users,
    required this.populatedUsers,
    required this.chatId,
  });

  List<Message> messages;
  bool read;
  List<String> users;
  List<UserDetails> populatedUsers;
  String chatId;

  factory ChatDetails.fromJson(Map<String, dynamic> json) => ChatDetails(
    messages: List<Message>.from(json["messages"].map((x) => Message.fromJson(x))),
    read: json["read"],
    users: List<String>.from(json["users"].map((x) => x)),
    populatedUsers: List<UserDetails>.from(json["populatedUsers"].map((x) => UserDetails.fromJson(x))),
    chatId: json["chat_id"],
  );
}

class Message {
  Message({
    required this.id,
    required this.message,
    required this.datetime,
    required this.user,
  });

  int id;
  String message;
  int datetime;
  String user;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json["id"],
    message: json["message"],
    datetime: json["datetime"],
    user: json["user"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "message": message,
    "datetime": datetime,
    "user": user,
  };
}