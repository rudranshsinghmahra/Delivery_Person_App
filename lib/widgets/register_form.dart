import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../provider/auth_provider.dart';
import '../screens/login_screen.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _emailTextEditingController =
      TextEditingController();
  final TextEditingController _phoneTextEditingController =
      TextEditingController();
  final TextEditingController _passwordTextEditingController =
      TextEditingController();
  final TextEditingController _confirmTextEditingController =
      TextEditingController();
  final TextEditingController _addressTextEditingController =
      TextEditingController();
  final TextEditingController _nameTextEditingController =
      TextEditingController();
  final TextEditingController _taglineTextEditingController =
      TextEditingController();
  String email = "";
  String password = "";
  String deliveryBoyName = "";
  String mobile = "0000000000";
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final authData = Provider.of<AuthProvider>(context);

    setState(() {
      _emailTextEditingController.text = authData.email;
      email = authData.email;
    });

    Future<String> uploadFile(String filePath) async {
      File file = File(filePath);
      FirebaseStorage storage = FirebaseStorage.instance;
      try {
        await storage
            .ref('deliveryPersonProfilePic/${_nameTextEditingController.text}')
            .putFile(file);
      } on FirebaseException catch (e) {
        print(e.code);
      }
      String downloadUrl = await storage
          .ref('deliveryPersonProfilePic/${_nameTextEditingController.text}')
          .getDownloadURL();
      return downloadUrl;
    }

    return isLoading
        ? Center(
            child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
          )
        : Form(
            key: formKey,
            child: Column(
              children: [
                //Delivery Boy Name
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter Name";
                      }
                      setState(() {
                        _nameTextEditingController.text = value;
                      });
                      setState(() {
                        deliveryBoyName = value;
                      });
                      return null;
                    },
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_outline),
                        labelText: "Name",
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2, color: Theme.of(context).primaryColor),
                        ),
                        focusColor: Theme.of(context).primaryColor),
                  ),
                ),
                //Delivery Boy Phone Number
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    controller: _phoneTextEditingController,
                    maxLength: 10,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter Mobile Number";
                      }
                      setState(() {
                        mobile = value;
                      });
                      return null;
                    },
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.phone),
                        labelText: "Mobile Number",
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2, color: Theme.of(context).primaryColor),
                        ),
                        focusColor: Theme.of(context).primaryColor),
                  ),
                ),
                //Delivery Boy email address
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    controller: _emailTextEditingController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        enabled: false,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.email),
                        labelText: "Email Address",
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2, color: Theme.of(context).primaryColor),
                        ),
                        focusColor: Theme.of(context).primaryColor),
                  ),
                ),
                // Delivery Boy password
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    controller: _passwordTextEditingController,
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter New Password";
                      }
                      if (value.length < 6) {
                        return "Minimum 6 Characters";
                      }
                      setState(() {
                        password = value;
                      });
                      return null;
                    },
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.vpn_key_outlined),
                        labelText: "New Password",
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2, color: Theme.of(context).primaryColor),
                        ),
                        focusColor: Theme.of(context).primaryColor),
                  ),
                ),
                // Delivery Boy password confirmation
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    controller: _confirmTextEditingController,
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Re-Enter Password";
                      }
                      if (_confirmTextEditingController.text !=
                          _passwordTextEditingController.text) {
                        return "Password Mis-Match";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.vpn_key_outlined),
                        labelText: "Confirm New Password",
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2, color: Theme.of(context).primaryColor),
                        ),
                        focusColor: Theme.of(context).primaryColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    maxLines: 6,
                    controller: _addressTextEditingController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Press Navigator Button";
                      }
                      if (authData.shopLatitude == null) {
                        return "Press Navigator Button";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: () {
                            _addressTextEditingController.text =
                                "Locating... Please wait";
                            authData.getCurrentAddress().then((value) {
                              if (value != null) {
                                setState(() {
                                  _addressTextEditingController.text =
                                      "${authData.placeName}\n${authData.shopAddress}";
                                });
                              } else {
                                showAlert(
                                    "Couldn't find your location. Try Again Later");
                              }
                            });
                          },
                          icon: const Icon(Icons.location_searching),
                        ),
                        prefixIcon: const Icon(Icons.contact_mail_outlined),
                        labelText: "Home Address",
                        enabledBorder: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2, color: Theme.of(context).primaryColor),
                        ),
                        focusColor: Theme.of(context).primaryColor),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Theme.of(context).primaryColor)),
                        onPressed: () {
                          if (authData.isPictureAvailable == true) {
                            if (formKey.currentState!.validate()) {
                              setState(() {
                                isLoading = true;
                              });
                              authData
                                  .registerDeliveryBoy(
                                      _emailTextEditingController.text,
                                      _passwordTextEditingController.text,
                                      _phoneTextEditingController.text)
                                  .then((value) {
                                if (value?.user?.uid != null) {
                                  //Vendor is registered Successfully. Now upload Profile Pic to Firestore.
                                  uploadFile(authData.image!.path)
                                      .then((value) {
                                    if (value != null) {
                                      //Save vendor details to database
                                      authData.saveDeliveryBoyDataToDatabase(
                                        url: value,
                                        name: deliveryBoyName,
                                        mobile: mobile,
                                        password: password,
                                        context: context,
                                      );
                                      setState(() {
                                        formKey.currentState?.reset();
                                        isLoading = false;
                                      });
                                    } else {
                                      showAlert(
                                          "Failed to upload Shop Profile Picture");
                                    }
                                  });
                                } else {
                                  //Registration Failed
                                }
                              });
                            }
                          } else {
                            showAlert("Shop Picture is Mandatory");
                          }
                        },
                        child: const Text(
                          "Register",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, LoginScreen.id);
                  },
                  child: RichText(
                    text: const TextSpan(text: '', children: [
                      TextSpan(
                          text: "Already have an account?",
                          style: TextStyle(color: Colors.black)),
                      TextSpan(
                        text: " Login",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          );
  }
}
