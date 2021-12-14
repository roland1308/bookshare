// To parse this JSON data, do
//
//     final userDetails = userDetailsFromJson(jsonString);

import 'dart:convert';

UserDetails userDetailsFromJson(String str) => UserDetails.fromJson(json.decode(str));
List<UserDetails> listUsersFromJson(String str) => List<UserDetails>.from(json.decode(str).map((x) => UserDetails.fromJson(x)));

String userDetailsToJson(UserDetails data) => json.encode(data.toJson());

class UserDetails {
  UserDetails({
    this.books,
    this.position,
    required this.userId,
    required this.email,
    required this.createdAt,
  });

  List<Book>? books;
  Position? position;
  String userId;
  String email;
  DateTime createdAt;

  factory UserDetails.fromJson(Map<String, dynamic> json) => UserDetails(
    books: json["books"] != null ? List<Book>.from(json["books"].map((x) => Book.fromJson(x))) : null,
    position: json["position"] != null ? Position.fromJson(json["position"]): null,
    userId: json["userId"],
    email: json["email"],
    createdAt: DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toJson() => {
    "books": books != null ? List<dynamic>.from(books!.map((x) => x.toJson())) : null,
    "position": position?.toJson(),
    "userId": userId,
    "email": email,
    "createdAt": createdAt.toIso8601String(),
  };
}

class Book {
  Book({
    required this.status,
    required this.owner,
    required this.availability,
    required this.code,
    required this.title,
    required this.coverLink,
  });

  String status;
  String owner;
  String availability;
  String code;
  String title;
  String coverLink;
  String? fcmToken;

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    status: json["status"],
    owner: json["owner"],
    availability: json["availability"].toString(),
    code: json["code"],
    title: json["title"],
    coverLink: json["coverLink"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "owner": owner,
    "availability": availability,
    "code": code,
    "title": title,
    "coverLink": coverLink,
  };
}

class Position {
  Position({
    required this.lng,
    required this.lat,
  });

  String lng;
  String lat;

  factory Position.fromJson(Map<String, dynamic> json) => Position(
    lng: json["lng"],
    lat: json["lat"],
  );

  Map<String, dynamic> toJson() => {
    "lng": lng,
    "lat": lat,
  };
}
