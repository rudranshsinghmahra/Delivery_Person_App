import 'package:chips_choice_null_safety/chips_choice_null_safety.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_delivery_application/provider/orders_provider.dart';
import 'package:grocery_delivery_application/services/firebase_services.dart';
import 'package:grocery_delivery_application/widgets/order_summary_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const String id = "home-screen";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseServices _services = FirebaseServices();
  final OrderProvider _orderProvider = OrderProvider();
  User? user = FirebaseAuth.instance.currentUser;
  int tag = 0;
  List<String> options = [
    "All Orders",
    "Accepted",
    "Picked-Up",
    "Out For Delivery",
    "Delivered",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text("My Orders"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            width: MediaQuery.of(context).size.width,
            child: ChipsChoice<int>.single(
                choiceStyle: const C2ChoiceStyle(
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                    color: Colors.grey),
                value: tag,
                onChanged: (val) {
                  if (val == 0) {
                    setState(() {
                      _orderProvider.status == null;
                    });
                  }
                  setState(() {
                    tag = val;
                    _orderProvider.status = options[val];
                  });
                },
                choiceItems: C2Choice.listFrom<int, String>(
                    source: options, value: (i, v) => i, label: (i, v) => v)),
          ),
          Container(
            child: StreamBuilder<QuerySnapshot>(
              stream: _services.orders
                  .where('deliveryBoy.email', isEqualTo: user?.email)
                  .where('orderStatus',
                      isEqualTo: tag == 0 ? null : _orderProvider.status)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }
                if (snapshot.data?.size == 0) {
                  //TODO: No orders screen
                  return Center(
                    child: Text(tag > 0
                        ? "No ${options[tag]} orders"
                        : "No Orders. Continue Shopping"),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Expanded(
                  child: ListView(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      return OrderSummaryCard(
                        documentSnapshot: document,
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
