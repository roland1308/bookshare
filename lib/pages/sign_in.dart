import 'package:book_share/controllers/system_controller.dart';
import 'package:book_share/database/user_repository.dart';
import 'package:book_share/localizations/i18n.dart';
import 'package:book_share/pages/sign_up.dart';
import 'package:book_share/services/helpers.dart';
import 'package:book_share/services/shared_prefs_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i18n_extension/i18n_widget.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final SystemController systemCtrl = Get.find<SystemController>();

  TextEditingController emailController =
      TextEditingController(text: "user01@user.com");
  TextEditingController password1Controller =
      TextEditingController(text: "123456");
  bool isLoading = false;
  bool isObscured1 = true;
  bool isRememberMe = false;
  final _formKey = GlobalKey<FormState>();

  var items = ["ES","EN","IT"];
  String _dropdownValue = "EN";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => isExitDesired(context),
      child: Scaffold(
        body: Container(
          decoration: backImageDecoration(),
          child: Align(
            child: SingleChildScrollView(
              child: Container(
                decoration: backTransparentDecoration(),
                padding: const EdgeInsets.all(40),
                width: MediaQuery.of(context).size.width * 0.95,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [


                      DropdownButton(
                          value: I18n.of(context).locale.languageCode.toUpperCase(),
                          icon: const Icon(Icons.arrow_downward),
                          onChanged: (String? newValue){
                            setState(() {
                              _dropdownValue = newValue!;
                              I18n.of(context).locale = Locale(newValue.toLowerCase(),"");
                            });
                          },
                          items: items.map(
                                  (String value)=>DropdownMenuItem(
                                  value: value,
                                  child: Text(value))).toList()

                      ),


                      const Image(image: AssetImage("assets/images/title.png")),
                      const SizedBox(height: 40),
                      TextFormField(
                        validator: (text) {
                          text ??= "";
                          if (!isEmail(text)) {
                            return "Incorrect email format!".i18n;
                          }
                          return null;
                        },
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.emailAddress,
                        controller: emailController,
                        decoration: buildInputDecoration(
                            hintText: "Email".i18n,
                            prefixIcon: const Icon(Icons.person_outline,
                                color: Colors.black26)),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        validator: (text) {
                          text ??= "";
                          if (text.length < 6) {
                            return "Password must be at least 6 characters length!".i18n;
                          }
                          return null;
                        },
                        cursorColor: Colors.black,
                        controller: password1Controller,
                        obscureText: isObscured1,
                        decoration: buildInputDecoration(
                          hintText: "Password".i18n,
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: Colors.black26),
                          suffixIcon: InkWell(
                            onTap: () {
                              setState(() {
                                isObscured1 = !isObscured1;
                              });
                            },
                            child: Icon(
                                isObscured1
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.black26),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                            checkColor: Colors.white,
                            value: isRememberMe,
                            onChanged: (bool? value) {
                              setState(() {
                                isRememberMe = value!;
                              });
                            },
                          ),
                          Text("Remember me".i18n)
                        ],
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.green)),
                          onPressed: isLoading
                              ? () {}
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    FocusScope.of(context).unfocus();
                                    Map<String, dynamic> user = {
                                      "email": emailController.text,
                                      "password": password1Controller.text,
                                    };
                                    Map<String, dynamic> result =
                                        await UserRepository().signIn(user);
                                    setState(() {
                                      isLoading = false;
                                    });
                                    if (result["success"]) {
                                      systemCtrl.setToken(result["token"]);
                                      Get.snackbar("Great!".i18n, "Login success".i18n,
                                          snackPosition: SnackPosition.BOTTOM);
                                      if (isRememberMe) {
                                        await setPrefsValue(
                                            "sharedToken", result["token"]);
                                      }
                                      systemCtrl.setIsLogged(true);

                                      /// Don't need to go to MyLibraryPage
                                      /// because with GETX systemCtrl help, the main()
                                      /// will redirect automatically
                                      // Navigator.pushAndRemoveUntil(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //       builder: (_) => MyLibraryPage(),
                                      //     ),
                                      //     (route) => false);
                                    } else {
                                      Get.defaultDialog(
                                          title: "Error",
                                          content: Text(result["message"]));
                                    }
                                  } else {
                                    Get.defaultDialog(
                                        title: "Error",
                                        content: Text(
                                            "Please correct input errors".i18n));
                                  }
                                },

                          child: isLoading
                              ? const CircularProgressIndicator()
                              : Text("Sign In".i18n),
                        ),
                      ),
                      const SizedBox(height: 40),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignUp(),
                              ));
                        },
                        child: RichText(
                            text: TextSpan(
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 20),
                                children: [
                              TextSpan(text: "Not yet registered?".i18n),
                              const TextSpan(
                                  text: " Sign Up!",
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold))
                            ])),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
