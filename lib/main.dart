import 'package:book_share/pages/my_library_page.dart';
import 'package:book_share/pages/sign_in.dart';
import 'package:book_share/services/shared_prefs_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'database/user_repository.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlay_support/overlay_support.dart';

import 'controllers/system_controller.dart';
import 'controllers/user_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'localizations/i18n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load();
  await MyI18n.loadTranslations();

  Get.put(SystemController());
  Get.put(UserController());

  runApp(I18n(child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /*Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        title: 'Notify',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        debugShowCheckedModeBanner: false,
        home: HomePage(),
      ),
    );
  }*/

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
    print(I18n.of(context).locale.languageCode);
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
            () => OverlaySupport(
              child: GetMaterialApp(
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  //GlobalWidgetsLocalizations.delegate,
                  //GlobalCupertinoLocalizations.delegate
                ],
                supportedLocales: const [
                  Locale('en'),
                  Locale('es'),
                  //Locale('it')
                ],
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                ),
                home: systemCtrl.isLogged.isTrue
                    ? const MyLibraryPage()
                    : const SignIn(),
              ),
            ),
          );
  }
}
