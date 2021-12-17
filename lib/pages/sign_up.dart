import 'package:book_share/controllers/system_controller.dart';
import 'package:book_share/database/user_repository.dart';
import 'package:book_share/localizations/i18n.dart';
import 'package:book_share/pages/my_library_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/helpers.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final systemCtrl = Get.put(SystemController());
  TextEditingController emailController = TextEditingController();
  TextEditingController password1Controller = TextEditingController();
  TextEditingController password2Controller = TextEditingController();
  bool isLoading = false;
  bool isObscured1 = true;
  bool isObscured2 = true;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        } else if (text != password2Controller.text) {
                          return "Passwords must coincide".i18n;
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
                    TextFormField(
                      validator: (text) {
                        text ??= "";
                        if (text.length < 6) {
                          return "Password must be at least 6 characters length!".i18n;
                        } else if (text != password1Controller.text) {
                          return "Passwords must coincide".i18n;
                        }
                        return null;
                      },
                      cursorColor: Colors.black,
                      controller: password2Controller,
                      obscureText: isObscured2,
                      decoration: buildInputDecoration(
                        hintText: "Repeat Password".i18n,
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: Colors.black26),
                        suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              isObscured2 = !isObscured2;
                            });
                          },
                          child: Icon(
                              isObscured2
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.black26),
                        ),
                      ),
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
                                  Map<String, dynamic> newUser = {
                                    "email": emailController.text,
                                    "password": password1Controller.text,
                                    "confirmPassword": password2Controller.text,
                                  };
                                  Map<String, dynamic> result =
                                      await UserRepository().signUp(newUser);
                                  if (result["success"]) {
                                    systemCtrl.setToken(result["token"]);
                                    systemCtrl.setIsLogged(true);
                                    Get.snackbar("Great!".i18n,
                                        "User registered successfully".i18n,
                                        snackPosition: SnackPosition.BOTTOM);
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const MyLibraryPage(),
                                        ),
                                        (route) => false);
                                  } else {
                                    Get.defaultDialog(
                                        title: "Error",
                                        content: Text(result["message"] ??
                                            "An error occurred, please retry".i18n));
                                  }
                                  setState(() {
                                    isLoading = false;
                                  });
                                } else {
                                  Get.defaultDialog(
                                    title: "Error",
                                    content: Text(
                                        "Please correct input errors".i18n),
                                  );
                                }
                              },
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : Text("Sign Up".i18n),
                      ),
                    ),
                    const SizedBox(height: 40),
                    InkWell(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                              fontSize: 20),
                          children: [
                            TextSpan(text: "Already registered?".i18n),
                            TextSpan(
                              text: " Sign In!".i18n,
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
