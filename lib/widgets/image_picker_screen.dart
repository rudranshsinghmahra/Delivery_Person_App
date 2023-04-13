import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';

class ShopPicCard extends StatefulWidget {
  const ShopPicCard({Key? key}) : super(key: key);

  @override
  State<ShopPicCard> createState() => _ShopPicCardState();
}

class _ShopPicCardState extends State<ShopPicCard> {
  @override
  Widget build(BuildContext context) {
    File? image;
    final authData = Provider.of<AuthProvider>(context);
    final Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: InkWell(
        onTap: () {
          authData.getImage().then((value) {
            setState(() {
              image = value;
              print("Image Url is $image");
              print("Image Value is $value");
            });
            if (value != null) {
              authData.isPictureAvailable = true;
            }
          });
        },
        child: SizedBox(
          height: size.height/3,
          width: size.width/1,
          child: Card(
            child: image?.path != null
                ? Image.asset(image!.path)
                : Center(
                    child: Container(
                      color: Colors.blue,
                      child: const Text(
                        "Add Shop Image",
                        style: TextStyle(fontSize: 20, color: Colors.black45),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
