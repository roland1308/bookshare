// To parse this JSON data, do
//
//     final bookSearchResult = bookSearchResultFromJson(jsonString);

import 'dart:convert';

BookSearchResult bookSearchResultFromJson(String str) =>
    BookSearchResult.fromJson(json.decode(str));

class BookSearchResult {
  BookSearchResult({
    required this.docs,
  });

  List<Doc> docs;

  factory BookSearchResult.fromJson(Map<String, dynamic> json) =>
      BookSearchResult(
        docs: List<Doc>.from(json["docs"].map((x) => Doc.fromJson(x))),
      );
}

class Doc {
  Doc({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.language,
    required this.authorKey,
  });

  String key;
  String title;
  String subtitle;
  List<String>? language;
  List<String>? authorKey;
  String imageLink = '';
  String author = '';

  factory Doc.fromJson(Map<String, dynamic> json) => Doc(
        key: json["key"],
        title: json["title"],
        subtitle: json["title"],
        language: json["language"] == null
            ? null
            : List.from(json["language"].map((x) => x)),
        authorKey: json["author_key"] == null
            ? null
            : List<String>.from(json["author_key"].map((x) => x)),
      );
}
