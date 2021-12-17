import 'package:book_share/pages/search_library_page.dart';
import 'package:flutter/material.dart';

class SignIn extends StatelessWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: const BoxDecoration(
              color: Colors.transparent,
              image: DecorationImage(
                image: AssetImage("assets/images/biblioteca_web.jpg"),
                fit: BoxFit.cover,
              )),
          child: Center(
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const SearchLibrary()),
                        (Route<dynamic> route) => false);
                  },
                  child: const Text("SIGN IN")))),
    );
  }
}
