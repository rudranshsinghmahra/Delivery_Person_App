import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);
  static const String id = "reset-password";

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  String email = "";
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    // final _authData = Provider.of<AuthProvider>(context);
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: formKey,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      "assets/forgot.png",
                      height: 250,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    RichText(
                      text: const TextSpan(text: '', children: [
                        TextSpan(
                          text: "Forgot Password",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                              fontSize: 18),
                        ),
                        TextSpan(
                          text:
                              "  Provide us your registered email, we will send you an email to reset your password",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.deepOrange),
                        ),
                      ]),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter your Email";
                        }
                        final bool isValid =
                            EmailValidator.validate(emailController.text);
                        if (!isValid) {
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
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.deepPurple)),
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                setState(() {
                                  isLoading = true;
                                });
                                // _authData.authDataResetPassword(email);
                                Navigator.pushReplacementNamed(
                                    context, LoginScreen.id);
                                showAlert(
                                    "If email exists, reset link has been sent successfully");
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            },
                            child: isLoading
                                ? const LinearProgressIndicator()
                                : const Text("Reset Password"),
                          ),
                        ),
                      ],
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
