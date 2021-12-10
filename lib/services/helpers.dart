import 'package:flutter/material.dart';
import 'package:get/get.dart';

InputDecoration buildInputDecoration({
  String? hintText,
  Icon? prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      hintText: hintText ?? "",
      filled: true,
      fillColor: Colors.white,
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black54),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      errorStyle: const TextStyle(color: Colors.black));
}

InputDecoration buildStatusDecoration({
  String? hintText,
}) {
  return InputDecoration(
    hintText: hintText ?? "",
    fillColor: Colors.white,
  );
}

bool isEmail(String text) {
  return RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(text);
}

BoxDecoration backImageDecoration() {
  return const BoxDecoration(
      color: Colors.transparent,
      image: DecorationImage(
        image: AssetImage("assets/images/biblioteca_web.jpg"),
        fit: BoxFit.cover,
      ));
}

BoxDecoration backTransparentDecoration() {
  return BoxDecoration(
      color: Colors.white.withOpacity(.7),
      borderRadius: const BorderRadius.all(Radius.circular(20)));
}


Future<bool> isExitDesired(context) async {
  return await Get.defaultDialog(
      title: "Exit BookShare",
      content: const Text("Do you really want to exit BookShare?"),
      textCancel: "No",
      onCancel: ()=>Navigator.of(context).pop(false),
      textConfirm: "Yes, please",
      onConfirm: ()=>Navigator.of(context).pop(true));
}