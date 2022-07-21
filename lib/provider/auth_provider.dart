import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';

import '../screens/home_screen.dart';

class AuthProvider extends ChangeNotifier {
  File? image;
  bool isPictureAvailable = false;
  double shopLatitude = 0.0;
  double shopLongitude = 0.0;
  String? shopAddress;
  String? placeName;
  String email = "";
  String mobileNumber = "";
  CollectionReference deliveryBoy =
      FirebaseFirestore.instance.collection('deliveryBoys');

  Future<File?> getImage() async {
    final ImagePicker _picker = ImagePicker();
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      image = File(pickedImage.path);
      isPictureAvailable = true;
      notifyListeners();
    } else {
      print("No Image Selected");
    }
    return image;
  }

  Future getCurrentAddress() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await location.getLocation();
    shopLatitude = _locationData.latitude!;
    shopLongitude = _locationData.longitude!;
    notifyListeners();

    final coordinates =
        Coordinates(_locationData.latitude, _locationData.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var shopAddress = addresses.first;
    this.shopAddress = shopAddress.addressLine;
    placeName = shopAddress.featureName;
    notifyListeners();
    return shopAddress;
  }

  // Email Registration
  Future<UserCredential?> registerDeliveryBoy(
      String email, String password, String mobile) async {
    this.email = email;
    mobileNumber = mobile;
    notifyListeners();
    UserCredential? userCredential;
    try {
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        notifyListeners();
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        notifyListeners();
      }
    } catch (e) {
      print(e.toString());
      notifyListeners();
    }
    return userCredential;
  }

  //Reset Password
  Future<void> authDataResetPassword(String email) async {
    this.email = email;
    notifyListeners();
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email)
          .whenComplete(() {});
    } catch (e) {
      print(e.toString());
      notifyListeners();
    }
  }

  getEmailAddress(email) {
    this.email = email;
    notifyListeners();
  }

  //Login Vendor
  Future<UserCredential?> loginDeliveryBoy(
      String email, String password) async {
    this.email = email;
    notifyListeners();
    UserCredential? userCredential;
    try {
      userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        notifyListeners();
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        notifyListeners();
      }
    } catch (e) {
      print(e.toString());
      notifyListeners();
    }
    return userCredential;
  }

  // Save Vendor Data to Firestore
  Future<void> saveDeliveryBoyDataToDatabase(
      {required String url,
      required String name,
      required String mobile,
      required String password,
      context}) async {
    User? user = FirebaseAuth.instance.currentUser;
    CollectionReference deliveryBoys =
        FirebaseFirestore.instance.collection('deliveryBoys');
    deliveryBoys.doc(email).update({
      'uid': user?.uid,
      'name': name,
      'password': password,
      'mobile': mobileNumber,
      'address': '$placeName:$shopAddress',
      'location': GeoPoint(shopLatitude, shopLongitude),
      'imageUrl': url,
      'accVerified': false // only verified vendors can sell their products
    }).whenComplete(() {
      Navigator.pushReplacementNamed(context, HomeScreen.id);
    });
    return;
  }
}
