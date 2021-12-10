import 'package:book_share/pages/search_library_page.dart';
import 'package:book_share/pages/search_users_page.dart';
import 'package:flutter/material.dart';

class AnimatedFloatingButtons extends StatefulWidget {
  const AnimatedFloatingButtons({
    Key? key,
  }) : super(key: key);

  @override
  State<AnimatedFloatingButtons> createState() =>
      _AnimatedFloatingButtonsState();
}

class _AnimatedFloatingButtonsState extends State<AnimatedFloatingButtons>
    with SingleTickerProviderStateMixin {
  Animation<double>? animation;
  AnimationController? controller;
  bool _isOpen = true;

  @override
  initState() {
    super.initState();

    controller = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    animation = Tween<double>(begin: 0, end: 1).animate(controller!);
    animation!.addListener(() {
      setState(() {});
    });
  }

  @override
  dispose() {
    super.dispose();
    controller?.dispose();
  }

  void openClose() {
    _isOpen = !_isOpen;
    if (_isOpen) {
      controller!.reverse();
    } else {
      controller!.forward();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned(
            width: 40,
            bottom: 10 + 50 * animation!.value,
            right: 20,
            child: FloatingActionButton(
              heroTag: null,
              onPressed: () {
                openClose();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SearchLibrary(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            ),
          ),
          if (animation!.value > 0)
            Positioned(
              bottom: 15 + 55 * animation!.value,
              right: 65,
              child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(animation!.value * .7),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20))),
                  child: const Center(
                      child: Text(
                    "Search within OpenLibrary.org",
                    style: TextStyle(color: Colors.white),
                  ))),
            ),
          Positioned(
            width: 40,
            bottom: 15 + 90 * animation!.value,
            right: 20,
            child: FloatingActionButton(
              heroTag: null,
              onPressed: () {
                openClose();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SearchUsers(),
                  ),
                );
              },
              child: const Icon(Icons.people),
            ),
          ),
          if (animation!.value > 0)
            Positioned(
              bottom: 15 + 100 * animation!.value,
              right: 65,
              child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(animation!.value * .7),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20))),
                  child: const Center(
                      child: Text(
                    "Search within users",
                    style: TextStyle(color: Colors.white),
                  ))),
            ),
          Positioned(
            width: 60,
            bottom: 10,
            right: 10,
            child: FloatingActionButton(
              heroTag: null,
              onPressed: () => openClose(),
              child: AnimatedIcon(
                  icon: AnimatedIcons.menu_close, progress: animation!),
            ),
          )
        ],
      ),
    );
  }
}
