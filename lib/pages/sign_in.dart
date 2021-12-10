import 'package:book_share/controllers/system_controller.dart';
import 'package:book_share/database/user_repository.dart';
import 'package:book_share/pages/sign_up.dart';
import 'package:book_share/services/helpers.dart';
import 'package:book_share/services/shared_prefs_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final SystemController systemCtrl = Get.find<SystemController>();

  TextEditingController emailController =
      TextEditingController(text: "renato@renato.com");
  TextEditingController password1Controller =
      TextEditingController(text: "123456");
  bool isLoading = false;
  bool isObscured1 = true;
  bool isRememberMe = false;
  final _formKey = GlobalKey<FormState>();

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
                      const Image(image: AssetImage("assets/images/title.png")),
                      const SizedBox(height: 40),
                      TextFormField(
                        validator: (text) {
                          text ??= "";
                          if (!isEmail(text)) {
                            return "Incorrect email format!";
                          }
                          return null;
                        },
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.emailAddress,
                        controller: emailController,
                        decoration: buildInputDecoration(
                            hintText: "Email",
                            prefixIcon: const Icon(Icons.person_outline,
                                color: Colors.black26)),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        validator: (text) {
                          text ??= "";
                          if (text.length < 6) {
                            return "Password must be at least 6 characters length!";
                          }
                          return null;
                        },
                        cursorColor: Colors.black,
                        controller: password1Controller,
                        obscureText: isObscured1,
                        decoration: buildInputDecoration(
                          hintText: "Password",
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
                          const Text("Remember me")
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
                                      Get.snackbar("Great!", "Login success",
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
                                        content: const Text(
                                            "Please correct input errors"));
                                  }
                                },
                          child: isLoading
                              ? const CircularProgressIndicator()
                              : const Text("Sign In"),
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
                            text: const TextSpan(
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 20),
                                children: [
                              TextSpan(text: "Not yet registered?"),
                              TextSpan(
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
