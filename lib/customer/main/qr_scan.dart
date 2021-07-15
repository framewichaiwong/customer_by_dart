import 'dart:convert';
import 'package:customer_by_dart/config/config.dart';
import 'package:customer_by_dart/customer/class/class_user_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'home.dart';
import 'package:qrscan/qrscan.dart' as scanner;

class QrCodeScan extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _QrCodeScan();
}

class _QrCodeScan extends State<QrCodeScan> {

  Future<Null> _scanQR() async{
    try{
      await Permission.camera.request(); ///Access to CAMERA.
      String? qrResult = await scanner.scan(); /// Scan QR Code

      var jsonData = jsonDecode(qrResult!);
      print("managerId: ${jsonData['managerId']}"); /// Test value to Console.
      print("NumberTable: ${jsonData['numberTable']}"); /// Test value to Console.
      QRData _qr = new QRData(jsonData['managerId'], jsonData['numberTable']);
      if(qrResult.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          new SnackBar(
            content: Text("กำลังอ่าน QR Code..."),
          ),
        );
        await http.get(Uri.parse("${Config.url}/userManager/listUser/${_qr.managerId}")).then((response) {
          print("Status Code => ${response.statusCode}");
          var jsonData = jsonDecode(response.body);
          var status = jsonData['status'];
          var data = jsonData['data'];
          List<UserManager> userManager = [];
          if(status==1){
            final _img64 = base64Decode(data['picture']);
            UserManager user = new UserManager(data['managerId'], data['name'], data['surName'], data['tel'], data['nameRestaurant'], data['numberTable'], data['address'], _img64);
            userManager.add(user);
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Home(userManager,_qr.numberTable)), (route) => false);
          }else{
            ScaffoldMessenger.of(context).showSnackBar(
              new SnackBar(
                content: Text("QR Code Error"),
              ),
            );
          }
        });
      }else {
        ScaffoldMessenger.of(context).showSnackBar(
          new SnackBar(
            content: Text("QR Code ไม่ถูกต้อง"),
          ),
        );
      }
    }catch (error) {
      setState(() {
        error.toString();
      });
    }
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

class QRData {
  int managerId;
  int numberTable;
  QRData(this.managerId,this.numberTable);
}