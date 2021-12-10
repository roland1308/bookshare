import 'package:book_share/components/show_book_by_tag.dart';
import 'package:book_share/models/user_details_model.dart';
import 'package:flutter/material.dart';

class GridViewBooks extends StatelessWidget {
  const GridViewBooks(
      {Key? key,
      required this.listToShow,
      required this.callBack1,
      required this.color1,
      required this.icon1,
      this.icon2,
      this.color2,
      this.callBack2})
      : super(key: key);

  final List<Book> listToShow;
  final Function callBack1;
  final Color color1;
  final Icon icon1;
  final Function? callBack2;
  final Color? color2;
  final Icon? icon2;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 2 / 3,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20),
      itemCount: listToShow.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            FocusScope.of(context).unfocus();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ShowBookByTag(
                    title: listToShow[index].title,
                    image: listToShow[index].coverLink),
              ),
            );
          },
          child: Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.only(bottom: 5),
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Hero(
                        tag: listToShow[index].coverLink,
                        child: Image.network(
                          listToShow[index].coverLink,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Expanded(
                      flex: 1,
                      child: Text(
                        listToShow[index].title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.fade,
                      ),
                    )
                  ],
                ),
                Positioned(
                  right: -5,
                  top: -5,
                  child: GestureDetector(
                    onTap: () => callBack1(listToShow[index]),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: color1.withOpacity(0.8),
                      child: icon1,
                    ),
                  ),
                ),
                if (color2 != null)
                  Positioned(
                    right: -5,
                    top: 35,
                    child: GestureDetector(
                      onTap: () => callBack2!(listToShow[index]),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: color2!.withOpacity(0.8),
                        child: icon2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
