import 'package:book_share/pages/my_library_page.dart';
import 'package:book_share/pages/sign_in.dart';
import 'package:book_share/services/shared_prefs_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/system_controller.dart';
import 'controllers/user_controller.dart';
import 'database/user_repository.dart';

void main() {
  Get.put(SystemController());
  Get.put(UserController());
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final SystemController systemCtrl = Get.find<SystemController>();
  bool isLoading = true;

  @override
  void initState() {
    checkForSharedToken();
    super.initState();
  }

  void checkForSharedToken() async {
    //await removePrefsKey("sharedToken");
    String sharedToken = await getPrefsValue("sharedToken");
    if (sharedToken != '') {
      systemCtrl.setToken(sharedToken);
      Map<String, dynamic> result =
          await UserRepository().getMyUserDetails(sharedToken);
      if (result["success"]) {
        systemCtrl.setIsLogged(true);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Container(
            decoration: const BoxDecoration(
                color: Colors.transparent,
                image: DecorationImage(
                  image: AssetImage("assets/images/biblioteca_web.jpg"),
                  fit: BoxFit.cover,
                )),
            child: const Center(child: CircularProgressIndicator()))
        : Obx(
            () => GetMaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              home: systemCtrl.isLogged.isTrue ? MyLibraryPage() : const SignIn(),
            ),
          );
  }
}
