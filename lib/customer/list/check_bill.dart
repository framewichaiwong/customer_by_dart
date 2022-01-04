import 'dart:convert';
import 'dart:io';

import 'package:customer_by_dart/config/config.dart';
import 'package:customer_by_dart/customer/class/class_cancel_order_menu.dart';
import 'package:customer_by_dart/customer/class/class_order.dart';
import 'package:customer_by_dart/customer/class/class_order_other_menu.dart';
import 'package:customer_by_dart/customer/class/class_user_manager.dart';
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

  List<ListOrder> _listOrderByCheckStatusForShowTotalPrice = [];
  List<ListOrder> _listOrder = [];
  List<ListOrderMakeStatus> _listMakeStatus = [];

  @override
  void initState(){
    super.initState();
    _getOrder();
  }

  /*@override
  void dispose() {
    _getOrder();
    super.dispose();
  }*/

  Future _getOrder() async{
    var response = await http.get(Uri.parse("${Config.url}/order/getOrderByManagerIdAndNumberTable/${userManager[0].managerId}/$numberTable"), headers: {'Accept': 'Application/json; charset=UTF-8'});
    var jsonData = jsonDecode(response.body);
    var data = jsonData['data'];
    List<ListOrder> listOrder = [];
    List<ListOrder> checkCancel = [];
    List<ListOrder> checkPassAndNotSent = [];
    List<ListOrderMakeStatus> listMakeStatus = []; /// Class name this page.
    List<ListOrder> listOrderByCheckStatusForShowTotalPrice = [];/// For check_status == "ส่งแล้ว" && "ยังไม่ส่ง".
    _listOrder = listOrder;
    _listMakeStatus = listMakeStatus; /// Class name this page. create for (if).
    _listOrderByCheckStatusForShowTotalPrice = listOrderByCheckStatusForShowTotalPrice;/// For check_status == "ส่งแล้ว" && "ยังไม่ส่ง".

    for(Map o in data) {
      var response = await http.get(Uri.parse("${Config.url}/orderOtherMenu/listForCustomer/${o['orderId']}"),headers: {'Accept': 'Application/json; charset=UTF-8'});
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data'];
      List<OrderOtherMenu> listOrderOtherMenu = [];
      if(data == null){
        listOrderOtherMenu = [];
      }else{
        for(Map m in data){
          OrderOtherMenu list = new OrderOtherMenu(m['orderOtherId'], m['orderOtherName'], m['orderOtherPrice'], m['orderId']);
          listOrderOtherMenu.add(list);
        }
      }
      // ListOrder lstOrder = new ListOrder(o['orderId'], o['numberMenu'], o['numberTable'], o['nameMenu'], o['priceMenu'], o['managerId'], o['makeStatus'],listOrderOtherMenu);
      // listOrder.add(lstOrder);

      /// For check_status == "ส่งแล้ว" && "ยังไม่ส่ง". ไว้สำหรับแสดงราคารวม total.
      if(o['makeStatus']=="ส่งแล้ว" || o['makeStatus']=="ยังไม่ส่ง"){
        ListOrder lstOrder = new ListOrder(o['orderId'], o['numberMenu'], o['numberTable'], o['nameMenu'], o['priceMenu'], o['managerId'], o['makeStatus'],listOrderOtherMenu);
        listOrderByCheckStatusForShowTotalPrice.add(lstOrder);
        checkPassAndNotSent.add(lstOrder); ///---
      }
      /// For check_status == "ยกเลิก".
      if(o['makeStatus']=="ยกเลิก"){
        ListOrder lstOrder = new ListOrder(o['orderId'], o['numberMenu'], o['numberTable'], o['nameMenu'], o['priceMenu'], o['managerId'], o['makeStatus'],listOrderOtherMenu);
        checkCancel.add(lstOrder); ///---
      }

      /// Class name this page.
      if(o['makeStatus']=="ส่งแล้ว" || o['makeStatus']=="ยกเลิก") {
        ListOrderMakeStatus listOrderMakeStatus = new ListOrderMakeStatus(o['makeStatus']);
        listMakeStatus.add(listOrderMakeStatus);
      }
    }

    /// สำหรับเก็บค่าที่ เช็คโดย "ส่งแล้ว" && "ยังไม่ส่ง".
    checkPassAndNotSent.sort((a,b) => a.orderId.compareTo(b.orderId));
    checkPassAndNotSent.forEach((passAndNotSent) {
      listOrder.add(passAndNotSent);
    });
    /// สำหรับเก็บค่าที่ เช็คโดย "ยกเลิก".
    checkCancel.sort((a,b) => a.orderId.compareTo(b.orderId));
    checkCancel.forEach((cancel) {
      listOrder.add(cancel);
    });
    // listOrder.sort((a,b) => a.orderId.compareTo(b.orderId));
    return _listOrder;
  }

  // Stream<void> _getOrder() async*{
  //   var response = await http.get(Uri.parse("${Config.url}/order/getOrderByManagerIdAndNumberTable/${userManager[0].managerId}/$numberTable"), headers: {'Accept': 'Application/json; charset=UTF-8'});
  //   var jsonData = jsonDecode(response.body);
  //   var data = jsonData['data'];
  //   List<ListOrder> listOrder = [];
  //   List<ListOrderMakeStatus> listMakeStatus = []; /// Class name this page.
  //   if(mounted){
  //     setState(() {
  //       _listOrder = listOrder;
  //       _listMakeStatus = listMakeStatus; /// Class name this page. create for (if).
  //     });
  //   }else{
  //     return;
  //   }
  //   for (Map o in data) {
  //     ListOrder lstOrder = new ListOrder(o['orderId'], o['numberMenu'], o['numberTable'], o['nameMenu'], o['priceMenu'], o['managerId'], o['makeStatus']);
  //     listOrder.add(lstOrder);
  //
  //     /// Class name this page.
  //     if(o['makeStatus']=="ทำเสร็จแล้ว") {
  //       ListOrderMakeStatus listOrderMakeStatus = new ListOrderMakeStatus(o['makeStatus']);
  //       listMakeStatus.add(listOrderMakeStatus);
  //     }
  //   }
  //   listOrder.sort((a,b) => a.orderId.compareTo(b.orderId));
  //   yield _listOrder;
  // }

  checkBill() async{
    Navigator.of(context).pop();
      if(_listOrder.length == _listMakeStatus.length){
        Map params = new Map();
        params['managerId'] = userManager[0].managerId.toString();
        params['numberTable'] = numberTable.toString();
        await http.post(Uri.parse("${Config.url}/tableCheckBill/save"),body: params,headers: {'Accept': 'Application/json; charset=UTF-8'}).then((response){
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
                var jsonData = jsonDecode(response.body);
                var status = jsonData['status'];
                if(status==1 && i==(_listOrder.length - 1)){
                  ScaffoldMessenger.of(context).showSnackBar(
                    new SnackBar(
                      content: Text("เรียกชำระเงินแล้ว"),
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
                content: Text("เรียกชำระเงินไปแล้ว โปรดรอสักครู่.."),
              ),
            );
          }
        });
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          new SnackBar(
            content: Text("โปรดรอรายการอาหารสักครู่ ก่อนการชำระเงิน"),
          ),
        );
      }
  }

  /// Widget.
  Text headerText(String string){
    return Text("$string",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),);
  }
  Text bodyText(String string){
    return Text("$string",style: TextStyle(fontSize: 14),);
  }

  // FutureBuilder buildFutureBuilder(orderId){
  //   return FutureBuilder(
  //     future: getOrderOtherMenu(orderId),
  //     builder: (BuildContext context, AsyncSnapshot snapshot) => snapshot.data == null
  //       ? Container()
  //       : ListViewForCheckBill(snapshot.data)
  //   );
  // }

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
                child: FutureBuilder(
                  future: _getOrder(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if(snapshot.data == null){
                      return Container(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }else{
                      return Column(
                        children: [
                          Container(
                            height: 40,
                            color: Colors.amber,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                      width: MediaQuery.of(context).size.width * 0.4,
                                      child: headerText("เมนู")
                                  ),
                                  headerText("ราคา"),
                                  headerText("จำนวน"),
                                  headerText("รวม"),
                                  SizedBox(width: MediaQuery.of(context).size.width * 0.1),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Expanded(
                            child: ListView.builder(
                              itemCount: snapshot.data.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Card(
                                  child: Container(
                                      color: Colors.white,
                                      child: snapshot.data[index].makeStatus == "ส่งแล้ว" /// Status condition
                                          ? ListTile(
                                            title: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                    width: MediaQuery.of(context).size.width * 0.4,
                                                    child: bodyText("${snapshot.data[index].nameMenu}")
                                                ),
                                                bodyText("${snapshot.data[index].priceMenu}"),
                                                bodyText("${snapshot.data[index].numberMenu}"),
                                                bodyText("${(snapshot.data[index].priceMenu * snapshot.data[index].numberMenu) + (snapshot.data[index].orderOtherMenu.length == 0 ?0 :snapshot.data[index].orderOtherMenu.map((e) => e.orderOtherPrice * snapshot.data[index].numberMenu).reduce((value, element) => value + element))}"),
                                              ],
                                            ),
                                            subtitle: Container(
                                              child: snapshot.data[index].orderOtherMenu==null
                                                  ? null
                                                  : ListViewForCheckBill(snapshot.data[index].orderOtherMenu),
                                            ),
                                            trailing: Container(
                                              width: 40,
                                              height: 25,
                                              // child: Icon(Icons.done,color: Colors.green,size: 32,),
                                              child: Text("ได้รับ",style: TextStyle(color: Colors.greenAccent),),
                                            ),
                                          )
                                          : snapshot.data[index].makeStatus == "ยังไม่ส่ง"
                                              ? ListTile(
                                                title: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Container(
                                                        width: MediaQuery.of(context).size.width * 0.4,
                                                        child: bodyText("${snapshot.data[index].nameMenu}")
                                                    ),
                                                    bodyText("${snapshot.data[index].priceMenu}"),
                                                    bodyText("${snapshot.data[index].numberMenu}"),
                                                    bodyText("${(snapshot.data[index].priceMenu * snapshot.data[index].numberMenu) + (snapshot.data[index].orderOtherMenu.length == 0 ?0 :snapshot.data[index].orderOtherMenu.map((e) => e.orderOtherPrice * snapshot.data[index].numberMenu).reduce((value, element) => value + element))}"),
                                                  ],
                                                ),
                                                subtitle: Container(
                                                  child: snapshot.data[index].orderOtherMenu==null
                                                      ? null
                                                      : ListViewForCheckBill(snapshot.data[index].orderOtherMenu),
                                                ),
                                                trailing: Container(
                                                  width: 40,
                                                  height: 25,
                                                  // child: CircularProgressIndicator(strokeWidth: 2),
                                                  child: Text("รอ..."),
                                                ),
                                              )
                                              : Container( /// "ยกเลิก"
                                                color: Colors.black12,
                                                child: ListTile(
                                                  title: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Container(
                                                        width: MediaQuery.of(context).size.width * 0.4,
                                                        child: bodyText("${snapshot.data[index].nameMenu}")
                                                      ),
                                                      bodyText("${snapshot.data[index].priceMenu}"),
                                                      bodyText("${snapshot.data[index].numberMenu}"),
                                                      bodyText("${(snapshot.data[index].priceMenu * snapshot.data[index].numberMenu) + (snapshot.data[index].orderOtherMenu.length == 0 ?0 :snapshot.data[index].orderOtherMenu.map((e) => e.orderOtherPrice * snapshot.data[index].numberMenu).reduce((value, element) => value + element))}"),
                                                    ],
                                                  ),
                                                  // subtitle: Container(
                                                  //   child: snapshot.data[index].orderOtherMenu==null
                                                  //     ? null
                                                  //     : ListViewForCheckBill(snapshot.data[index].orderOtherMenu),
                                                  // ),
                                                  subtitle: Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        child: snapshot.data[index].orderOtherMenu==null
                                                            ? null
                                                            : ListViewForCheckBill(snapshot.data[index].orderOtherMenu),
                                                      ),
                                                      ListViewCancelOrderMenu(snapshot.data[index].orderId), /// Call
                                                    ],
                                                  ),
                                                  trailing: Container(
                                                    width: 40,
                                                    height: 25,
                                                    // child: Icon(Icons.clear,color: Colors.red),
                                                    child: Text("ยกเลิก",style: TextStyle(color: Colors.red),),
                                                  ),
                                                ),
                                              )
                                  ),
                                );
                              },
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      height: 40,
                                      color: Colors.yellowAccent,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Text("ราคารวม :",style: TextStyle(fontSize: 18),),
                                          Text("${_listOrderByCheckStatusForShowTotalPrice.length <= 0 ?0 :(_listOrderByCheckStatusForShowTotalPrice.map((listOrder) => (listOrder.priceMenu * listOrder.numberMenu) + (listOrder.orderOtherMenu.isEmpty ?0 :listOrder.orderOtherMenu.map((e) => e.orderOtherPrice * listOrder.numberMenu).reduce((value, element) => value + element))).reduce((value, element) => value + element))}" + " บาท",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height: 40,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      //primary: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text("เรียกชำระเงิน",style: TextStyle(fontSize: 18),),
                                    onPressed: () {
                                      if(_listOrder.length >= 1){
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
                                      }else{
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          new SnackBar(
                                            content: Text("คุณยังไม่มีรายการอาหาร..!"),
                                          ),
                                        );
                                      }
                                    }
                                  ),
                                ),
                              ),
                            ],
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

/// Create for listview.builder (order_other_menu).
class ListViewForCheckBill extends StatelessWidget {
  List<OrderOtherMenu?> listOrderOtherMenu;
  ListViewForCheckBill(this.listOrderOtherMenu);


  /// Widget.
// Text headerText(String string){
//   return Text("$string",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),);
// }
  Text bodyText(String string){
    return Text("$string",style: TextStyle(fontSize: 14));
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: listOrderOtherMenu.length,
      itemBuilder: (BuildContext context, int index) => Column(
        children: [
          Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.48,
                child: bodyText("+${listOrderOtherMenu[index]!.orderOtherName}"),
              ),
              bodyText("${listOrderOtherMenu[index]!.orderOtherPrice}"),
            ],
          ),
        ],
      ),
    );
  }
}


/// Create for listview.builder (cancel_order_menu) ในกรณียกเลิกเมนูอาหาร.
class ListViewCancelOrderMenu extends StatefulWidget {
  int orderId;
  ListViewCancelOrderMenu(this.orderId);


  @override
  State<StatefulWidget> createState() => _ListViewCancelOrderMenu(orderId);
}

class _ListViewCancelOrderMenu extends State<ListViewCancelOrderMenu> {
  int orderId;
  _ListViewCancelOrderMenu(this.orderId);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCancelOrderMenu();
  }

  Future getCancelOrderMenu() async{
    var response = await http.get(Uri.parse("${Config.url}/cancelOrderMenu/list/$orderId"),headers: {'Accept': 'Application/json; charset=UTF-8'});
    var jsonData = jsonDecode(response.body);
    var data = jsonData['data'];
    List<CancelOrderMenu> list = [];
    CancelOrderMenu cancelOrderMenu = new CancelOrderMenu(data['cancelId'], data['cancelReason'], data['orderId']);
    list.add(cancelOrderMenu);
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getCancelOrderMenu(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if(snapshot.data == null || snapshot.data.length == 0){
          return Container();
        }else{
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: snapshot.data.length,
            itemBuilder: (context, int index) => Text("*** ${snapshot.data[index].cancelReason}",style: TextStyle(color: Colors.red),),
          );
        }
      }
    );
  }
}
