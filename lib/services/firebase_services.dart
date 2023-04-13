import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseServices {
  CollectionReference deliveryBoy =
      FirebaseFirestore.instance.collection('deliveryBoys');

  CollectionReference orders = FirebaseFirestore.instance.collection('orders');

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<DocumentSnapshot> validateUser(id) async {
    DocumentSnapshot result = await deliveryBoy.doc(id).get();
    return result;
  }

  Future<DocumentSnapshot> getCustomerDetails(id) async {
    DocumentSnapshot documentSnapshot = await users.doc(id).get();
    return documentSnapshot;
  }

  Future<void> updateStatus({id, status}) {
    return orders.doc(id).update({
      'orderStatus': status,
    });
  }
}
