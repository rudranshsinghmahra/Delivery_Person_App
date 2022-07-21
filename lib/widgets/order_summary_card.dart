import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:grocery_delivery_application/services/firebase_services.dart';
import 'package:intl/intl.dart';
import '../services/order_services.dart';

class OrderSummaryCard extends StatefulWidget {
  const OrderSummaryCard({Key? key, required this.documentSnapshot})
      : super(key: key);
  final DocumentSnapshot documentSnapshot;

  @override
  State<OrderSummaryCard> createState() => _OrderSummaryCardState();
}

class _OrderSummaryCardState extends State<OrderSummaryCard> {
  final OrderService _orderService = OrderService();
  final FirebaseServices _services = FirebaseServices();
  DocumentSnapshot? customer;

  @override
  void initState() {
    _services
        .getCustomerDetails(widget.documentSnapshot['userId'])
        .then((value) {
      if (value != null) {
        setState(() {
          customer = value;
        });
      } else {
        print("No Data Found");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 14,
                  child: _orderService.statusIcon(widget.documentSnapshot)),
              title: Text(
                widget.documentSnapshot['orderStatus'],
                style: TextStyle(
                  fontSize: 15,
                  color: _orderService.statusColor(widget.documentSnapshot),
                ),
              ),
              subtitle: Text(
                "On ${DateFormat.yMMMd().format(
                  DateTime.parse(widget.documentSnapshot['timestamp']),
                )}",
                style: const TextStyle(fontSize: 1),
              ),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Payment Type : ${widget.documentSnapshot['cod'] == true ? "Cash On Delivery" : "Paid Online"}",
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Amount : Rs ${widget.documentSnapshot['total'].toStringAsFixed(0)}",
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            //TODO: Customer Name, contact number
            customer != null
                ? ListTile(
                    title: Row(
                      children: [
                        const Text(
                          "Customer : ",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${customer?['firstName']} ${customer?['lastName']}",
                          style: TextStyle(fontSize: 12),
                        )
                      ],
                    ),
                    subtitle: Text(
                      customer?['address'],
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.map_sharp),
                          onPressed: () {
                            _orderService.launchMap(customer?['latitude'],
                                customer?['longitude'], customer?['firstName']);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.phone),
                          onPressed: () {
                            FlutterPhoneDirectCaller.callNumber(
                                customer?['number']);
                          },
                        ),
                      ],
                    ),
                  )
                : Container(),
            ExpansionTile(
              title: const Text(
                "Order Details",
                style: TextStyle(fontSize: 12, color: Colors.black),
              ),
              subtitle: const Text(
                "View order details",
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              children: [
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.documentSnapshot['products'].length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Image.network(widget.documentSnapshot['products']
                            [index]['productImage']),
                      ),
                      title: Text(widget.documentSnapshot['products'][index]
                          ['productName']),
                      subtitle: Text(
                          "${widget.documentSnapshot['products'][index]['qty']} x Rs ${widget.documentSnapshot['products'][index]['price']} = Rs ${widget.documentSnapshot['products'][index]['total'].toStringAsFixed(0)}"),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 12, right: 12, top: 8, bottom: 8),
                  child: Card(
                    elevation: 8,
                    color: Colors.green,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Seller : ',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                widget.documentSnapshot['seller']['shopName'],
                                style: const TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          (int.parse(widget.documentSnapshot['discount']) > 0)
                              ? Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          'Discount : ',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "${widget.documentSnapshot['discount']}",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          'Discount Code: ',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "${widget.documentSnapshot['discountCode']}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                )
                              : Container(),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              const Text(
                                'Delivery Fee: ',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "${widget.documentSnapshot['deliveryFee']}",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
            statusContainer(widget.documentSnapshot),
          ],
        ),
      ),
    );
  }

  showDialogBox(title, status, documentId) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.INFO,
      animType: AnimType.BOTTOMSLIDE,
      title: title,
      desc: 'Are you sure',
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        EasyLoading.show(status: "Updating Status");
        status == "Accepted"
            ? _orderService.updateOrderStatus(documentId, status).then((value) {
                EasyLoading.showSuccess("Updated Successfully");
              })
            : _orderService.updateOrderStatus(documentId, status).then((value) {
                EasyLoading.showSuccess("Updated Successfully");
              });
      },
    ).show();
  }

  showCodConfirmationDialog(title, status, documentId) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.INFO,
      animType: AnimType.BOTTOMSLIDE,
      title: title,
      desc: 'Make sure you have received the Cash On Delivery payment',
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        EasyLoading.show();
        _services
            .updateStatus(id: documentId, status: "Delivered")
            .then((value) {
          EasyLoading.showSuccess("You have successfully Delivered the Order");
        });
      },
    ).show();
  }

  Widget statusContainer(DocumentSnapshot documentSnapshot) {
    if (documentSnapshot['deliveryBoy']['name'].length > 1) {
      if (documentSnapshot['orderStatus'] == "Accepted") {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: 50,
          color: Colors.grey[300],
          child: Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6.0, bottom: 4.0),
              child: ElevatedButton(
                onPressed: () {
                  EasyLoading.show();
                  _services
                      .updateStatus(
                          id: documentSnapshot.id, status: "Picked-Up")
                      .then((value) {
                    EasyLoading.showSuccess(
                        "You have successfully picked up the order");
                  });
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      _orderService.statusColor(documentSnapshot)),
                ),
                child: const Text(
                  "Update Status : Order Picked-Up",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        );
      }

      if (documentSnapshot['orderStatus'] == "Picked-Up") {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: 50,
          color: Colors.grey[300],
          child: Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6.0, bottom: 4.0),
              child: ElevatedButton(
                onPressed: () {
                  EasyLoading.show();
                  _services
                      .updateStatus(
                          id: documentSnapshot.id, status: "Out For Delivery")
                      .then((value) {
                    EasyLoading.showSuccess(
                        "The package is Out For Delivery by you");
                  });
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      _orderService.statusColor(documentSnapshot)),
                ),
                child: const Text(
                  "Update Status : Out For Delivery",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        );
      }

      if (documentSnapshot['orderStatus'] == "Out For Delivery") {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: 50,
          color: Colors.grey[300],
          child: Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6.0, bottom: 4.0),
              child: ElevatedButton(
                onPressed: () {
                  if (documentSnapshot['cod'] == true) {
                    showCodConfirmationDialog("COD Payment Received ?",
                        'Delivered', documentSnapshot.id);
                  } else {
                    EasyLoading.show();
                    _services
                        .updateStatus(
                            id: documentSnapshot.id, status: "Delivered")
                        .then((value) {
                      EasyLoading.showSuccess(
                          "You have successfully Delivered the Order");
                    });
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      _orderService.statusColor(documentSnapshot)),
                ),
                child: const Text(
                  "Update Status : Order Delivered",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        );
      }

      if (documentSnapshot['orderStatus'] == "Delivered") {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: 50,
          color: Colors.grey[300],
          child: Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6.0, bottom: 4.0),
              child: ElevatedButton(
                onPressed: () {},
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      _orderService.statusColor(documentSnapshot)),
                ),
                child: const Text(
                  "Order Completed",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        );
      }
    }

    return Container(
      color: Colors.grey[300],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  showDialogBox(
                      "Accept Order", "Accepted", documentSnapshot.id);
                },
                child: const Text("Accept"),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: AbsorbPointer(
                absorbing: documentSnapshot['orderStatus'] == "Rejected"
                    ? true
                    : false,
                child: ElevatedButton(
                  onPressed: () {
                    showDialogBox(
                        "Cancel Order", "Rejected", documentSnapshot.id);
                  },
                  child: const Text("Reject"),
                  style: ButtonStyle(
                    backgroundColor:
                        documentSnapshot['orderStatus'] == "Rejected"
                            ? MaterialStateProperty.all(Colors.grey)
                            : MaterialStateProperty.all(Colors.red),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
