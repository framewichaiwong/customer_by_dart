import 'dart:convert';
import 'package:customer_by_dart/config/config.dart';
import 'package:customer_by_dart/customer/class/class_user_manager.dart';
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
            duration: Duration(seconds: 1),
          ),
        );
        await http.get(Uri.parse("${Config.url}/userManager/listUser/${_qr.managerId}"),headers: {'Accept': 'Application/json; charset=UTF-8'}).then((response) {
          print("--- status Code ===>>> ${response.statusCode}");
          var jsonData = jsonDecode(response.body);
          var status = jsonData['status'];
          var data = jsonData['data'];
          List<UserManager> userManager = [];
          if(status==1){
            ScaffoldMessenger.of(context).showSnackBar(
              new SnackBar(
                content: Text("สแกนสำเร็จ กำลังเข้าสู่รายการ"),
                duration: Duration(seconds: 1),
              )
            );
            var _img64 = base64Decode(data['picture']);
            UserManager user = new UserManager(data['managerId'], data['name'], data['surName'], data['tel'], data['nameRestaurant'], data['numberTableTotal'], data['address'], _img64);
            userManager.add(user);
            Future.delayed(Duration(seconds: 3),() => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Home(userManager,_qr.numberTable)), (route) => false));
          }else{
            ScaffoldMessenger.of(context).showSnackBar(
              new SnackBar(
                content: Text("QR Code Error"),
                duration: Duration(seconds: 1),
              ),
            );
          }
        });
      }else {
        ScaffoldMessenger.of(context).showSnackBar(
          new SnackBar(
            content: Text("QR Code ไม่ถูกต้อง"),
            duration: Duration(seconds: 1),
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
          color: Colors.white,
          child: Center(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                Container(
                  // color: Colors.green,
                  child: Image.asset("images_for_app/homepage_icon/restaurant_1.png"),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        height: MediaQuery.of(context).size.height * 0.15,
        width: MediaQuery.of(context).size.width,
        child: FittedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FloatingActionButton.extended(
                onPressed: () => _scanQR(),
                label: Container(
                  width: 150,
                  child: Icon(
                    Icons.qr_code_scanner,
                    size: 40,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Text("Scan QR Code for continue",style: TextStyle(fontSize: 25),textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QRData {
  int managerId;
  int numberTable;
  QRData(this.managerId,this.numberTable);
}