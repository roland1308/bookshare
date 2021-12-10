import 'dart:convert';

import 'package:book_share/models/book_search_model.dart';
import 'package:http/http.dart' as http;

const String kBaseUrl = 'http://openlibrary.org/';

class OpenLibraryDB {
  Future<Map<String, dynamic>> searchTitle(String title) async {
    title.replaceAll(' ', '+');
    http.Response response = await http
        .get(Uri.parse(kBaseUrl + 'search.json?title=$title&limit=10'));
    if (response.statusCode == 200) {
      final BookSearchResult bookSearchResult =
          bookSearchResultFromJson(response.body);

      for (Doc book in bookSearchResult.docs) {
        String imgLink = await OpenLibraryDB().getCoverByKey(book.key);
        String authorName = book.authorKey != null
            ? await OpenLibraryDB().getAuthorByKey(book.authorKey![0])
            : '';
        if (imgLink == '') imgLink = book.key;
        book.imageLink = 'https://covers.openlibrary.org/b/id/$imgLink-L.jpg';
        book.author = authorName;
      }
      return ({'success': true, 'response': bookSearchResult.docs});
    } else {
      return ({
        'success': false,
      });
    }
  }

  Future<String> getCoverByKey(String key) async {
    http.Response response = await http.get(Uri.parse(kBaseUrl + '$key.json'));
    if (response.statusCode == 200) {
      Map<String, dynamic> decodedBody = jsonDecode(response.body);
      if (decodedBody['covers'] != null) {
        return (decodedBody['covers'][0].toString());
      } else {
        return '';
      }
    } else {
      print("ERROR");
      return '';
    }
  }

  Future<String> getAuthorByKey(String key) async {
    http.Response response =
        await http.get(Uri.parse(kBaseUrl + 'authors/$key.json'));
    if (response.statusCode == 200) {
      Map<String, dynamic> decodedBody = jsonDecode(response.body);
      return (decodedBody['name']);
    } else {
      print("ERROR");
      return '';
    }
  }
}
