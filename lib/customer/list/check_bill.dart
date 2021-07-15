import 'dart:convert';

import 'package:customer_by_dart/config/config.dart';
import 'package:customer_by_dart/customer/class/class_order.dart';
import 'package:customer_by_dart/customer/class/class_user_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CheckBill extends StatefulWidget {
  List<UserManager> userManager;
  int numberTable;
  CheckBill(this.userManager,this.numberTable);

  @override
  State<StatefulWidget> createState() => _CheckBill(userManager,numberTable);
}

class _CheckBill extends State<CheckBill> {
  List<UserManager> userManager;
  int numberTable;
  _CheckBill(this.userManager,this.numberTable);

  List<ListOrder> _listOrder = [];
  List<ListOrderMakeStatus> _listMakeStatus = [];

  ///Test Notification
  //FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

  @override
  void dispose() {
    _getOrder();
    super.dispose();
  }

  Stream<void> _getOrder() async*{
    var response = await http.get(Uri.parse("${Config.url}/order/getOrderByManagerIdAndNumberTable/${userManager[0].managerId}/$numberTable"), headers: {'Accept': 'Application/json; charset=UTF-8'});
    var jsonData = jsonDecode(response.body);
    var data = jsonData['data'];
    List<ListOrder> listOrder = [];
    List<ListOrderMakeStatus> listMakeStatus = []; /// Class name this page.
    if(mounted){
      setState(() {
        _listOrder = listOrder;
        _listMakeStatus = listMakeStatus; /// Class name this page.
      });
    }else{
      return;
    }
    for (Map o in data) {
      ListOrder lstOrder = new ListOrder(o['orderId'], o['numberMenu'], o['numberTable'], o['nameMenu'], o['priceMenu'], o['managerId'], o['makeStatus']);
      listOrder.add(lstOrder);

      /// Class name this page.
      if(o['makeStatus']=="ทำเสร็จแล้ว") {
        ListOrderMakeStatus listOrderMakeStatus = new ListOrderMakeStatus(o['makeStatus']);
        listMakeStatus.add(listOrderMakeStatus);
      }
    }
    yield _listOrder;
  }

  checkBill() {
    Navigator.of(context).pop();
    if(_listOrder.length >= 1){
      if(_listOrder.length == _listMakeStatus.length){
        Map params = new Map();
        params['managerId'] = userManager[0].managerId.toString();
        params['numberTable'] = numberTable.toString();
        http.post(Uri.parse("${Config.url}/tableCheckBill/save"),body: params,headers: {'Accept': 'Application/json; charset=UTF-8'}).then((response){
          print(response.body); /// show data on console
          var jsonData = jsonDecode(response.body);
          var status = jsonData['status'];
          if(status == 1){
            Map params = new Map();
            for(int i=0; i<_listOrder.length; i++){ /// Save listOrder to new OrderCheckBill
              params['numberMenu'] = _listOrder[i].numberMenu.toString();
              params['numberTable'] = numberTable.toString();
              params['nameMenu'] = _listOrder[i].nameMenu;
              params['priceMenu'] = _listOrder[i].priceMenu.toString();
              params['managerId'] = userManager[0].managerId.toString();
              params['makeStatus'] = _listOrder[i].makeStatus.toString();
              http.post(Uri.parse("${Config.url}/orderCheckBill/save"),body: params,headers: {'Accept': 'Application/json; charset=UTF-8'}).then((response){
                print(response.body);
                var jsonData = jsonDecode(response.body);
                var status = jsonData['status'];
                if(status==1 && i==(_listOrder.length - 1)){
                  ScaffoldMessenger.of(context).showSnackBar(
                    new SnackBar(
                      content: Text("เรียกชำระเงินแล้ว",style: TextStyle(fontSize: 20),),
                    ),
                  );
                }/*else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    new SnackBar(
                      content: Text("รายการอาหารยังไม่เสร็จทั้งหมด"),
                    ),
                  );
                }*/
              });
            }
          }else{
            ScaffoldMessenger.of(context).showSnackBar(
              new SnackBar(
                content: Text("เรียกชำระเงินไปแล้ว โปรดรอสักครู่..",style: TextStyle(fontSize: 20),),
              ),
            );
          }
        });
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          new SnackBar(
            content: Text("โปรดรอรายการอาหารสักครู่ ก่อนการชำระเงิน",style: TextStyle(fontSize: 20),),
          ),
        );
      }
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        new SnackBar(
          content: Text("คุณยังไม่มีรายการอาหาร..!",style: TextStyle(fontSize: 20),),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: SafeArea(
        child: Card(
          color: Colors.red[100],
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: 300,
                    color: Colors.red[300],
                    child: Center(
                      child: Text("รายการที่สั่ง : " + "โต๊ะ " + "$numberTable", style: TextStyle(fontSize: 25,color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: _getOrder(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    print("data is : $snapshot");
                    if (snapshot.data == null){
                      return Container(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }else{
                      return Column(
                        children: [
                          Container(
                            height: 50,
                            color: Colors.amber,
                            child: ListTile(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("เมนู",style: TextStyle(fontSize: 20)),
                                  Text("ราคา",style: TextStyle(fontSize: 20)),
                                ],
                              ),
                              trailing: Text("         "),
                            ),
                          ),
                          SizedBox(height: 8),
                          Expanded(
                            child: ListView.builder(
                              itemCount: snapshot.data.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                    color: Colors.white,
                                    child: snapshot.data[index].makeStatus == "ทำเสร็จแล้ว" /// Status condition
                                        ? ListTile(
                                      title: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("${snapshot.data[index].nameMenu}",style: TextStyle(fontWeight: FontWeight.bold),),
                                          Text("${snapshot.data[index].priceMenu * snapshot.data[index].numberMenu}" + " บาท",style: TextStyle(fontWeight: FontWeight.bold),),
                                        ],
                                      ),
                                      subtitle: Text("${snapshot.data[index].priceMenu}" + " บาท x " + "${snapshot.data[index].numberMenu}"),
                                      trailing: Container(
                                        width: 25,
                                        height: 25,
                                        child: Icon(Icons.done,color: Colors.green,size: 32,),
                                      ),
                                    )
                                        : ListTile(
                                      title: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("${snapshot.data[index].nameMenu}",style: TextStyle(fontWeight: FontWeight.bold),),
                                          Text("${snapshot.data[index].priceMenu * snapshot.data[index].numberMenu}" + " บาท",style: TextStyle(fontWeight: FontWeight.bold),),
                                        ],
                                      ),
                                      subtitle: Text("${snapshot.data[index].priceMenu}" + " บาท x " + "${snapshot.data[index].numberMenu}"),
                                      trailing: Container(
                                        width: 25,
                                        height: 25,
                                        child: CircularProgressIndicator(strokeWidth: 2,),
                                      ),
                                    )
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                color: Colors.yellowAccent,
                                child: ListTile(
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("ราคารวม :",style: TextStyle(fontSize: 20),),
                                      Text("${_listOrder.length > 0 ? _listOrder.map((listOrder) => listOrder.priceMenu * listOrder.numberMenu).reduce((value, element) => value + element) : 0}" + " บาท",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  //primary: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text("เรียกชำระเงิน",style: TextStyle(fontSize: 18),),
                                onPressed: (){
                                  print(_listOrder.length);/// Show Status
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context){
                                        return AlertDialog(
                                          content: SingleChildScrollView(
                                            child: ListBody(
                                              children: [
                                                Text("ต้องการเรียกชำระเงิน",textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold),),
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: ElevatedButton(
                                                child: Text("ยืนยัน"),
                                                onPressed: checkBill,
                                              ),
                                            ),
                                            SizedBox(width: 100),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: ElevatedButton(
                                                child: Text("ยกเลิก"),
                                                onPressed: (){
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                  );
                                },
                                /*onPressed: () async{ /// Test notification
                                  var androidDetails = new AndroidNotificationDetails("Channel ID", "Desi programmer", "This is my channel", importance: Importance.Max);
                                  var iSODetails = new IOSNotificationDetails();
                                  var generalNotificationDetails = new NotificationDetails(androidDetails,iSODetails);
                                  for(int i=0; i<_listOrder.length; i++){
                                    await flutterLocalNotificationsPlugin.show(i, "โต๊ะ : $numberTable", "${_listOrder[i].nameMenu} x${_listOrder[i].numberMenu}", generalNotificationDetails, payload: "frame");
                                  }
                                },*/
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ListOrderMakeStatus { /// Check Status for use if().
  String listMakeStatus;
  ListOrderMakeStatus(this.listMakeStatus);
}