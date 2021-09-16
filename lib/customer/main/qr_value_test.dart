
import 'dart:convert';

import 'package:customer_by_dart/config/config.dart';
import 'package:customer_by_dart/customer/class/class_user_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'home.dart';

class QRValue extends StatefulWidget {
  @override
  _QRValueState createState() => _QRValueState();
}

class _QRValueState extends State<QRValue> {

  int numberTable = 1;
  int managerId = 3;

  @override
  void initState() {
    super.initState();
    _scanQR();
  }

  void _scanQR() async{
    await http.get(Uri.parse("${Config.url}/userManager/listUser/$managerId")).then((response) {
      print("Status Code => ${response.statusCode}");
      var jsonData = jsonDecode(response.body);
      var status = jsonData['status'];
      var data = jsonData['data'];
      List<UserManager> userManager = [];
      if(status==1){
        final _img64 = base64Decode(data['picture']);
        UserManager user = new UserManager(data['managerId'], data['name'], data['surName'], data['tel'], data['nameRestaurant'], data['numberTable'], data['address'], _img64);
        userManager.add(user);
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Home(userManager,numberTable)), (route) => false);
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          new SnackBar(
            content: Text("QR Code Error"),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: SafeArea(
        child: Card(
          color: Colors.red[100],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                      width: 300,
                      color: Colors.red[300],
                      child: Center(
                        child: Text(
                          "Application Restaurant",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            //decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Scan QR Code for continue",
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
                    Icon(
                      Icons.qr_code_scanner,
                      size: 200,
                      color: Colors.black,
                    ),
                  ],
                ),
                SizedBox(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        //icon: Icon(Icons.camera_alt),
        label: Container(
          width: 150,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt,
                size: 40,
              ),
              SizedBox(width: 5,),
              Text(
                "Scan",
                style: TextStyle(fontSize: 25),
              ),
            ],
          ),
        ),
        onPressed: _scanQR,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}