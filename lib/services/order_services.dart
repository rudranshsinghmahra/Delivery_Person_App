import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderService {
  CollectionReference orders = FirebaseFirestore.instance.collection('orders');

  Future updateOrderStatus(documentId, status) async {
    var result = await orders.doc(documentId).update({
      'orderStatus': status,
    });
    return result;
  }

  Color statusColor(DocumentSnapshot documentSnapshot) {
    if (documentSnapshot['orderStatus'] == "Accepted") {
      return Colors.blueGrey;
    }
    if (documentSnapshot['orderStatus'] == "Picked-Up") {
      return Colors.pink;
    }
    if (documentSnapshot['orderStatus'] == "Out For Delivery") {
      return Colors.purple;
    }
    if (documentSnapshot['orderStatus'] == "Delivered") {
      return Colors.green;
    }
    return Colors.orange;
  }

  Icon statusIcon(DocumentSnapshot documentSnapshot) {
    if (documentSnapshot['orderStatus'] == "Accepted") {
      return Icon(
        Icons.assignment_turned_in_outlined,
        color: statusColor(documentSnapshot),
        size: 22,
      );
    }
    if (documentSnapshot['orderStatus'] == "Picked-Up") {
      return Icon(
        Icons.cases,
        color: statusColor(documentSnapshot),
        size: 22,
      );
    }
    if (documentSnapshot['orderStatus'] == "Out For Delivery") {
      return Icon(
        Icons.delivery_dining,
        color: statusColor(documentSnapshot),
        size: 22,
      );
    }
    if (documentSnapshot['orderStatus'] == "Delivered") {
      return Icon(
        Icons.shopping_bag_outlined,
        color: statusColor(documentSnapshot),
        size: 22,
      );
    }
    return Icon(
      Icons.assignment_turned_in_outlined,
      color: statusColor(documentSnapshot),
      size: 22,
    );
  }

  void launchCall(number) async => await canLaunchUrl(number)
      ? await launchUrl(number)
      : throw "Could not launch $number";

  void launchMap(lat,long, name) async {
    final availableMaps = await MapLauncher.installedMaps;

    await availableMaps.first.showMarker(
        coords: Coords(lat,long), title: name);
  }
}
