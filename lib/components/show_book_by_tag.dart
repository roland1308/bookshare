import 'package:flutter/material.dart';

class ShowBookByTag extends StatelessWidget {
  const ShowBookByTag({Key? key, required this.image, required this.title})
      : super(key: key);

  final String image;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: InkWell(
        onTap: () => Navigator.pop(context),
        child: Container(
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
              padding: const EdgeInsets.all(40),
              width: MediaQuery.of(context).size.width * 0.95,
              child: Hero(
                tag: image,
                child: Image.network(
                  image,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
