import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_delivery_application/provider/auth_provider.dart';
import 'package:grocery_delivery_application/screens/home_screen.dart';
import 'package:grocery_delivery_application/screens/registration_screen.dart';
import 'package:grocery_delivery_application/screens/reset_password_screen.dart';
import 'package:grocery_delivery_application/services/firebase_services.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static const String id = 'login-screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;
  Icon? icon;
  bool _isVisible = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String email = "";
  String password = "";
  final formKey = GlobalKey<FormState>();
  final FirebaseServices _services = FirebaseServices();
  @override
  Widget build(BuildContext context) {
    var authData = Provider.of<AuthProvider>(context);
    return SafeArea(
      child: Scaffold(
          body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        height: 80,
                      ),
                      FittedBox(
                        child: const Text(
                          "DELIVERY APP - LOGIN",
                          style: TextStyle(
                              fontFamily: 'Anton',
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter your Email";
                    }
                    final bool _isValid =
                        EmailValidator.validate(emailController.text);
                    if (!_isValid) {
                      return "Invalid Email Format";
                    }
                    setState(() {
                      email = value;
                    });
                    return null;
                  },
                  controller: emailController,
                  decoration: const InputDecoration(
                    focusedBorder: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(),
                    contentPadding: EdgeInsets.zero,
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter a password";
                    }
                    if (value.length < 6) {
                      return "Minimum 6 Characters";
                    }
                    setState(() {
                      password = value;
                    });
                    return null;
                  },
                  controller: passwordController,
                  obscureText: !_isVisible,
                  decoration: InputDecoration(
                      suffixIcon: GestureDetector(
                        child: _isVisible
                            ? const Icon(Icons.visibility)
                            : const Icon(Icons.visibility_off),
                        onTap: () {
                          setState(() {
                            _isVisible = !_isVisible;
                          });
                        },
                      ),
                      focusedBorder: const OutlineInputBorder(),
                      enabledBorder: const OutlineInputBorder(),
                      contentPadding: EdgeInsets.zero,
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.vpn_key)),
                ),
                const SizedBox(
                  height: 20,
                ),
                // Row(
                //   children: [
                //     Expanded(
                //       child: GestureDetector(
                //         onTap: () {
                //           Navigator.pushNamed(context, ResetPasswordScreen.id);
                //         },
                //         child: const Text(
                //           "Forgot Password?",
                //           style: TextStyle(fontWeight: FontWeight.bold),
                //           textAlign: TextAlign.end,
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.deepPurple)),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            EasyLoading.show(status: "Please wait...");
                            _services.validateUser(email).then((value) {
                              if (value.exists) {
                                if (value['password'] == password) {
                                  authData
                                      .loginDeliveryBoy(emailController.text,
                                          passwordController.text)
                                      .then((value) {
                                    if (value?.user?.uid != null) {
                                      EasyLoading.showSuccess(
                                              "Login Successfully")
                                          .then((value) {
                                        Navigator.pushReplacementNamed(
                                            context, HomeScreen.id);
                                      });
                                      emailController.clear();
                                      passwordController.clear();
                                    } else {
                                      EasyLoading.showInfo(
                                              "Need to complete registration")
                                          .then((value) {
                                        authData.getEmailAddress(email);
                                        Navigator.pushNamed(
                                            context, RegistrationScreen.id);
                                      });
                                    }
                                  });
                                } else {
                                  EasyLoading.showError("Invalid Password");
                                }
                              } else {
                                EasyLoading.showError(
                                    "${email} is not registered as our delivery boy");
                              }
                            });
                          }
                        },
                        child: isLoading
                            ? const Center(
                                child: LinearProgressIndicator(),
                              )
                            : const Text(
                                "Login",
                                style: TextStyle(fontSize: 20),
                              ),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                        context, RegistrationScreen.id);
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: '',
                      children: [
                        TextSpan(
                            text: "Don't have an account?",
                            style: TextStyle(color: Colors.black)),
                        TextSpan(
                          text: " Register",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
