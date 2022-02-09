import 'dart:convert';
import 'dart:io';

import 'package:customer_by_dart/config/config.dart';
import 'package:customer_by_dart/customer/class/class_cancel_order_menu.dart';
import 'package:customer_by_dart/customer/class/class_order.dart';
import 'package:customer_by_dart/customer/class/class_order_other_menu.dart';
import 'package:customer_by_dart/customer/class/class_user_manager.dart';
import 'package:customer_by_dart/customer/list/pay_transfer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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

  // var numberFormat = NumberFormat("#,##0.00"); /// Format price.
  var numberFormat = NumberFormat("#,###"); /// Format price.

  int statusPayEdit = 0;
  int statusNotPay = 0;

  List<ListOrder> _listOrderByCheckStatusForShowTotalPrice = [];
  List<ListOrder> _listOrder = [];
  List<ListOrderMakeStatus> _listMakeStatus = [];

  int tableCheckBillId = 0;
  int? _priceTotal;

  @override
  void initState(){
    super.initState();
    _getOrder();
    _getTableCheckBillByNotPay();
    _getTableCheckByPayEdit();
  }

  /*@override
  void dispose() {
    _getOrder();
    super.dispose();
  }*/

  Future _getOrder() async{
    var response = await http.get(Uri.parse("${Config.url}/order/getOrderByManagerIdAndNumberTableAndTableCheckBillId/${userManager[0].managerId}/$numberTable/$tableCheckBillId"), headers: {'Accept': 'Application/json; charset=UTF-8'});
    var jsonData = jsonDecode(response.body);
    var data = jsonData['data'];
    List<ListOrder> listOrder = [];
    List<ListOrder> checkCancel = [];
    List<ListOrder> checkPassAndNotSent = [];
    List<ListOrderMakeStatus> listMakeStatus = []; /// Class name this page.
    List<ListOrder> listOrderByCheckStatusForShowTotalPrice = [];/// For check_status == "ส่งแล้ว" && "ยังไม่ส่ง".
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
        ListOrder lstOrder = new ListOrder(o['orderId'], o['numberMenu'], o['numberTable'], o['nameMenu'], o['priceMenu'], o['managerId'], o['makeStatus'], o['tableCheckBillId'],listOrderOtherMenu);
        listOrderByCheckStatusForShowTotalPrice.add(lstOrder);
        checkPassAndNotSent.add(lstOrder); ///---
      }
      /// For check_status == "ยกเลิก".
      if(o['makeStatus']=="ยกเลิก"){
        ListOrder lstOrder = new ListOrder(o['orderId'], o['numberMenu'], o['numberTable'], o['nameMenu'], o['priceMenu'], o['managerId'], o['makeStatus'], o['tableCheckBillId'],listOrderOtherMenu);
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
    /// /// Price Total.
    if(listOrderByCheckStatusForShowTotalPrice.isEmpty){
      _priceTotal = 0;
    }else{
      _priceTotal = listOrderByCheckStatusForShowTotalPrice.map((list) => (list.numberMenu * list.priceMenu) + (list.orderOtherMenu.length<=0 ?0 :list.orderOtherMenu.map((e) => e.orderOtherPrice * list.numberMenu).reduce((value, element) => value + element))).reduce((value, element) => value + element);
    }
    // listOrder.sort((a,b) => a.orderId.compareTo(b.orderId));
    _listOrder = listOrder;
    _listMakeStatus = listMakeStatus; /// Class name this page. create for (if).
    _listOrderByCheckStatusForShowTotalPrice = listOrderByCheckStatusForShowTotalPrice;

    return _listOrder;
  }

  Future _getTableCheckBillByNotPay() async{
    String _paymentStatus = "ยังไม่จ่าย"; /// ใช้สำหรับเรียก.
    Map params = new Map();
    params['managerId'] = userManager[0].managerId.toString();
    params['numberTable'] = numberTable.toString();
    var response = await http.post(Uri.parse("${Config.url}/tableCheckBill/check/$_paymentStatus"),body: params,headers: {'Accept': 'Application/json; charset=UTF-8'});
    var jsonData = jsonDecode(response.body);
    if(jsonData['status'] == 1){
      statusNotPay = 0;
      statusNotPay = jsonData['status'];
    }else{
      statusNotPay = 0;
    }
    return statusNotPay;
  }
  Future _getTableCheckByPayEdit() async{
    String _paymentStatus = "แก้ไขการโอนเงิน"; /// ใช้สำหรับเรียก.
    Map params = new Map();
    params['managerId'] = userManager[0].managerId.toString();
    params['numberTable'] = numberTable.toString();
    var response = await http.post(Uri.parse("${Config.url}/tableCheckBill/check/$_paymentStatus"),body: params,headers: {'Accept': 'Application/json; charset=UTF-8'});
    var jsonData = jsonDecode(response.body);
    if(jsonData['status'] == 1){
      statusPayEdit = 0;
      statusPayEdit = jsonData['status'];
    }else{
      statusPayEdit = 0;
    }
    return statusPayEdit;
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

  ///
  _onCallCheckBill() async{
    if(_listOrder.length >= 1){
      if(_priceTotal == 0){
        return showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            content: Text("รายการถูกยกเลิกทั้งหมด ต้องการปิดการชำระเงินหรือไม่",textAlign: TextAlign.center),
            actions: [
              Column(
                children: [
                  Center(
                    child: Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                        ),
                        child: Text("ยืนยัน"),
                        onPressed: () => _priceTotalIsZero(),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red[300],
                        ),
                        child: Text("ย้อนกลับ"),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }else{
        if(_listOrder.length == _listMakeStatus.length){
          String _paymentStatus = "ยังไม่จ่าย";
          Map params = new Map();
          params['managerId'] = userManager[0].managerId.toString();
          params['numberTable'] = numberTable.toString();
          var response = await http.post(Uri.parse("${Config.url}/tableCheckBill/check/$_paymentStatus"),body: params,headers: {'Accept': 'Application/json; charset=UTF-8'});
          var jsonData = jsonDecode(response.body);
          if(jsonData['status'] == 1){
            ScaffoldMessenger.of(context).showSnackBar(
              new SnackBar(
                content: Text("เรียกชำระเงินไปแล้ว โปรดรอสักครู่.."),
                duration: Duration(seconds: 1),
              ),
            );
          }else{
            showModalBottomSheet(
                context: context,
                builder: (BuildContext context) => Container(
                  child: Wrap(
                    children: [
                      Card(
                        child: ListTile(
                          title: Center(
                            child: Text("จ่ายด้วยการโอน"),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => PayByTransfer(userManager[0],numberTable,_listOrderByCheckStatusForShowTotalPrice))).then((value) => setState((){_getTableCheckByPayEdit();_getTableCheckBillByNotPay();}));
                          },
                        ),
                      ),
                      Card(
                        child: ListTile(
                          title: Center(
                            child: Text("จ่ายด้วยเงินสด"),
                          ),
                          onTap: () => _checkBillDialog(),
                        ),
                      ),
                      Card(
                        color: Colors.red[300],
                        child: ListTile(
                          title: Center(
                            child: Text("ย้อนกลับ"),
                          ),
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                )
            );
          }
        }else{
          ScaffoldMessenger.of(context).showSnackBar(
              new SnackBar(
                content: Text("โปรดรอรายการอาหารสักครู่ ก่อนการชำระเงิน"),
                duration: Duration(seconds: 1),
              )
          );
        }
      }
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        new SnackBar(
          content: Text("คุณยังไม่มีรายการอาหาร..!"),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  /// _Price_Total = 0;
  /// ลูกค้าต้องการ "ยกเลิก"
  _priceTotalIsZero() async{
    Navigator.of(context).pop();

    String _paymentType = "ยกเลิก";
    String _paymentStatus = "ยกเลิก";
    Map params = new Map();
    params['managerId'] = userManager[0].managerId.toString();
    params['numberTable'] = numberTable.toString();
    params['paymentType'] = _paymentType;
    params['paymentStatus'] = _paymentStatus;
    params['priceTotal'] = _priceTotal.toString();
    await http.post(Uri.parse("${Config.url}/tableCheckBill/save"),body: params,headers: {'Accept': 'Application/json; charset=UTF-8'}).then((response) async{
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data'];
      if(data != null){
        int _tableCheckBillId = 0; ///Set for call (FK) in order_menu.
        Map params = new Map();
        params['tableCheckBillId'] = data['tableCheckBillId'].toString();
        var response = await http.post(Uri.parse("${Config.url}/order/orderUpdateTableCheckBillIdByCustomer/${userManager[0].managerId}/$numberTable/$_tableCheckBillId"),body: params,headers: {'Accept': 'Application/json; charset=UTF-8'});
        var jsonData = jsonDecode(response.body);
        var status = jsonData['status'];
        if(status == 1){
          setState(() {
            ScaffoldMessenger.of(context).showSnackBar(
                new SnackBar(
                  content: Text("ปิดบิลเรียบร้อยแล้ว"),
                  duration: Duration(seconds: 1),
                )
            );
          });
        }
      }
    });
  }

  _checkBillDialog() {
    Navigator.pop(context);
    return showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("ชำระด้วยเงินสด",textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold),),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("จำนวน : $_priceTotal บาท",textAlign: TextAlign.center,style: TextStyle(fontSize: 25,color: Colors.blue),),
            ),
            actions: [
              Column(
                children: [
                  Center(
                    child: Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                        ),
                        child: Text("ยืนยัน"),
                        onPressed: () => _checkBill(),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red[300],
                        ),
                        child: Text("ย้อนกลับ"),
                        onPressed: () => Navigator.pop(context)
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }
    );
  }

  _checkBill() async{
    Navigator.of(context).pop();

    String _paymentType = "ชำระด้วยเงินสด";
    String _paymentStatus = "ยังไม่จ่าย";
    Map params = new Map();
    params['managerId'] = userManager[0].managerId.toString();
    params['numberTable'] = numberTable.toString();
    params['paymentType'] = _paymentType;
    params['paymentStatus'] = _paymentStatus;
    params['priceTotal'] = _priceTotal.toString();
    await http.post(Uri.parse("${Config.url}/tableCheckBill/save"),body: params,headers: {'Accept': 'Application/json; charset=UTF-8'}).then((response){
      var jsonData = jsonDecode(response.body);
      var status = jsonData['status'];
      if(status == 1){
        setState(() {
          _getTableCheckBillByNotPay();
          _getTableCheckByPayEdit();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          new SnackBar(
            content: Text("เรียกชำระเงินแล้ว"),
            duration: Duration(seconds: 1),
          )
        );
      }
    });
  }

  /// Widget.
  Text headerText(String string){
    return Text("$string",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),);
  }
  Text headerCenter(String string){
    return Text("$string",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),textAlign: TextAlign.center);
  }
  Text bodyText(String string){
    return Text("$string",style: TextStyle(fontSize: 14));
  }
  Text bodyNumberMenu(String string){
    return Text("$string",style: TextStyle(fontSize: 14),textAlign: TextAlign.center);
  }
  Text bodyPrice(String string){
    return Text("${numberFormat.format(int.parse(string))}",style: TextStyle(fontSize: 14),textAlign: TextAlign.center);
  }
  Text bodySumPrice(String string){
    return Text("${numberFormat.format(int.parse(string))}",style: TextStyle(fontSize: 14),textAlign: TextAlign.right);
  }
  Text bodyTotalPrice(String string){
    return Text("${numberFormat.format(int.parse(string))} บาท",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: SafeArea(
        child: Card(
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  // color: Colors.grey[500],
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: Text("รายการที่สั่ง : " + "โต๊ะ " + "$numberTable", style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold,color: Colors.black),
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
                            height: 45,
                            color: Colors.amber,
                            child: ListTile(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    child: headerText("เมนู")
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.14,
                                    child: headerCenter("ราคา"),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.18,
                                    child: headerCenter("จำนวน"),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.14,
                                    child: headerCenter("รวม"),
                                  ),
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
                                  color: Colors.grey[200],
                                  child: Container(
                                      child: snapshot.data[index].makeStatus == "ส่งแล้ว" /// Status condition
                                          ? Stack(
                                            alignment: Alignment.bottomRight,
                                            children: [
                                              ListTile(
                                                title: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Container(
                                                      width: MediaQuery.of(context).size.width * 0.38,
                                                      child: bodyText("${snapshot.data[index].nameMenu}")
                                                    ),
                                                    Container(
                                                      width: MediaQuery.of(context).size.width * 0.15,
                                                      child: bodyPrice("${snapshot.data[index].priceMenu}"),
                                                    ),
                                                    Container(
                                                      width: MediaQuery.of(context).size.width * 0.1,
                                                      child: bodyNumberMenu("${snapshot.data[index].numberMenu}"),
                                                    ),
                                                    Container(
                                                      width: MediaQuery.of(context).size.width * 0.15,
                                                      child: bodySumPrice("${(snapshot.data[index].priceMenu * snapshot.data[index].numberMenu) + (snapshot.data[index].orderOtherMenu.length == 0 ?0 :snapshot.data[index].orderOtherMenu.map((e) => e.orderOtherPrice * snapshot.data[index].numberMenu).reduce((value, element) => value + element))}"),
                                                    ),
                                                  ],
                                                ),
                                                subtitle: Container(
                                                  child: snapshot.data[index].orderOtherMenu==null
                                                      ? null
                                                      : ListViewForCheckBill(snapshot.data[index].orderOtherMenu),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(right: 10,bottom: 5),
                                                child: Container(
                                                  height: 25,
                                                  child: Text("ได้รับ",style: TextStyle(color: Colors.green[600],fontWeight: FontWeight.bold)),
                                                ),
                                              ),
                                            ],
                                          )
                                          : snapshot.data[index].makeStatus == "ยังไม่ส่ง"
                                              ? Stack(
                                                alignment: Alignment.bottomRight,
                                                children: [
                                                  ListTile(
                                                    title: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Container(
                                                          width: MediaQuery.of(context).size.width * 0.38,
                                                          child: bodyText("${snapshot.data[index].nameMenu}")
                                                        ),
                                                        Container(
                                                          width: MediaQuery.of(context).size.width * 0.15,
                                                          child: bodyPrice("${snapshot.data[index].priceMenu}"),
                                                        ),
                                                        Container(
                                                          width: MediaQuery.of(context).size.width * 0.1,
                                                          child: bodyNumberMenu("${snapshot.data[index].numberMenu}"),
                                                        ),
                                                        Container(
                                                          width: MediaQuery.of(context).size.width * 0.15,
                                                          child: bodySumPrice("${(snapshot.data[index].priceMenu * snapshot.data[index].numberMenu) + (snapshot.data[index].orderOtherMenu.length == 0 ?0 :snapshot.data[index].orderOtherMenu.map((e) => e.orderOtherPrice * snapshot.data[index].numberMenu).reduce((value, element) => value + element))}"),
                                                        ),
                                                      ],
                                                    ),
                                                    subtitle: Container(
                                                      child: snapshot.data[index].orderOtherMenu==null
                                                          ? null
                                                          : ListViewForCheckBill(snapshot.data[index].orderOtherMenu),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 10,bottom: 5),
                                                    child: Container(
                                                      height: 25,
                                                      // child: CircularProgressIndicator(strokeWidth: 2),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                        children: [
                                                          Text("รอ",style: TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.right),
                                                          SizedBox(width: 5),
                                                          Container(
                                                            height: 10,
                                                            width: 10,
                                                            child: CircularProgressIndicator(),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                              : Container( /// "ยกเลิก"
                                                color: Colors.black12,
                                                child: Stack(
                                                  alignment: Alignment.bottomRight,
                                                  children: [
                                                    ListTile(
                                                      title: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Container(
                                                            width: MediaQuery.of(context).size.width * 0.38,
                                                            child: bodyText("${snapshot.data[index].nameMenu}")
                                                          ),
                                                          Container(
                                                            width: MediaQuery.of(context).size.width * 0.15,
                                                            child: bodyPrice("${snapshot.data[index].priceMenu}"),
                                                          ),
                                                          Container(
                                                            width: MediaQuery.of(context).size.width * 0.1,
                                                            child: bodyNumberMenu("${snapshot.data[index].numberMenu}"),
                                                          ),
                                                          Container(
                                                            width: MediaQuery.of(context).size.width * 0.15,
                                                            child: bodySumPrice("${(snapshot.data[index].priceMenu * snapshot.data[index].numberMenu) + (snapshot.data[index].orderOtherMenu.length == 0 ?0 :snapshot.data[index].orderOtherMenu.map((e) => e.orderOtherPrice * snapshot.data[index].numberMenu).reduce((value, element) => value + element))}"),
                                                          ),
                                                        ],
                                                      ),
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
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: 10,bottom: 5),
                                                      child: Container(
                                                        height: 25,
                                                        // child: Icon(Icons.clear,color: Colors.red),
                                                        child: Text("ยกเลิก",style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),textAlign: TextAlign.right),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                  ),
                                );
                              },
                            ),
                          ),
                          Card(
                            color: Colors.grey[200],
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    height: 40,
                                    // color: Colors.yellowAccent,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Text("รวมทั้งหมด :",style: TextStyle(fontSize: 18),),
                                        Container(
                                          child: _priceTotal == 0
                                              ? bodyTotalPrice("${0}")
                                              : bodyTotalPrice("$_priceTotal"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.only(left: 8,right: 8),
                                //   child: Container(
                                //     width: MediaQuery.of(context).size.width * 0.7,
                                //     child: ElevatedButton(
                                //       style: ElevatedButton.styleFrom(
                                //           primary: Colors.green[600],
                                //         // shape: RoundedRectangleBorder(
                                //         //   borderRadius: BorderRadius.circular(10),
                                //         // ),
                                //       ),
                                //       child: Text("ชำระเงิน",style: TextStyle(fontSize: 18)),
                                //       onPressed: () => setState(() {
                                //         _getOrder();
                                //         _onCallCheckBill();
                                //       }),
                                //     ),
                                //   ),
                                // ),
                                ///
                                Padding(
                                  padding: const EdgeInsets.only(left: 8,right: 8),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 0.7,
                                    child: statusPayEdit == 1 /// กรณีแก้ไขรูปสลิป
                                        ? ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.amber[500],
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.edit),
                                                Text("ชำระเงินผิดพลาด"),
                                              ],
                                            ),
                                            onPressed: () => setState(() {
                                              print("ชำระเงินผิดพลาด");
                                              _getTableCheckByPayEdit();
                                              _getTableCheckBillByNotPay();
                                              }),
                                          )
                                        : statusNotPay == 1 /// กรณียังไม่จ่าย
                                            ? ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  primary: Colors.red[300],
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.refresh),
                                                    Text("รอดำเนินการชำระเงิน"),
                                                  ],
                                                ),
                                                onPressed: () => setState(() {
                                                  print("รอดำเนินการชำระเงิน");
                                                  _getTableCheckByPayEdit();
                                                  _getTableCheckBillByNotPay();
                                                }),
                                              )
                                            : ElevatedButton( /// กรณีเรียกชำระเงิน
                                                style: ElevatedButton.styleFrom(
                                                    primary: Colors.green[600],
                                                ),
                                                child: Text("ชำระเงิน",style: TextStyle(fontSize: 18)),
                                                onPressed: () => setState(() {
                                                  _getOrder();
                                                  _onCallCheckBill();
                                                }),
                                              ),
                                  ),
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.only(left: 8,right: 8),
                                //   child: Container(
                                //     width: MediaQuery.of(context).size.width * 0.7,
                                //     child: statusPayEdit == 1 /// กรณีแก้ไขรูปสลิป
                                //         ? ElevatedButton(
                                //             style: ElevatedButton.styleFrom(
                                //               primary: Colors.amber[500],
                                //             ),
                                //             child: Row(
                                //               mainAxisAlignment: MainAxisAlignment.center,
                                //               children: [
                                //                 Icon(Icons.edit),
                                //                 Text("แก้ไขการโอนเงิน"),
                                //               ],
                                //             ),
                                //             onPressed: () {
                                //               print("แก้ไขการโอนเงิน");
                                //               _getTableCheckByPayEdit();
                                //               _getTableCheckBillByNotPay();
                                //               // print("statusNotPay ===>> $statusNotPay");
                                //               // print("statusPayEdit ===>> $statusPayEdit");
                                //
                                //               setState(() {
                                //                 print("statusNotPay ===>> $statusNotPay");
                                //                 print("statusPayEdit ===>> $statusPayEdit");
                                //               });
                                //             },
                                //           )
                                //         : statusNotPay == 1 /// กรณียังไม่จ่าย
                                //             ? ElevatedButton(
                                //                 style: ElevatedButton.styleFrom(
                                //                   primary: Colors.red[300],
                                //                 ),
                                //                 child: Row(
                                //                   mainAxisAlignment: MainAxisAlignment.center,
                                //                   children: [
                                //                     Icon(Icons.refresh),
                                //                     Text("รอดำเนินการชำระเงิน"),
                                //                   ],
                                //                 ),
                                //                 onPressed: () {
                                //                   print("รอดำเนินการชำระเงิน");
                                //                   _getTableCheckByPayEdit();
                                //                   _getTableCheckBillByNotPay();
                                //                   // print("statusNotPay ===>> $statusNotPay");
                                //                   // print("statusPayEdit ===>> $statusPayEdit");
                                //                   setState(() {
                                //                     print("statusNotPay ===>> $statusNotPay");
                                //                     print("statusPayEdit ===>> $statusPayEdit");
                                //                   });
                                //                 },
                                //               )
                                //             : ElevatedButton( /// กรณีเรียกชำระเงิน
                                //                 style: ElevatedButton.styleFrom(
                                //                   primary: Colors.green[600],
                                //                 ),
                                //                 child: Text("ชำระเงิน",style: TextStyle(fontSize: 18)),
                                //                 onPressed: () {
                                //                   print("ชำระเงิน");
                                //                   _getTableCheckByPayEdit();
                                //                   _getTableCheckBillByNotPay();
                                //                   print("statusNotPay ===>> $statusNotPay");
                                //                   print("statusPayEdit ===>> $statusPayEdit");
                                //
                                //                   _getOrder();
                                //                   _onCallCheckBill();
                                //                 },
                                //               ),
                                //   ),
                                // ),
                              ],
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
  Text bodyPrice(String string){
    return Text("$string",style: TextStyle(fontSize: 14),textAlign: TextAlign.center);
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
                width: MediaQuery.of(context).size.width * 0.4,
                child: bodyText("+${listOrderOtherMenu[index]!.orderOtherName}"),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.17,
                child: bodyPrice("${listOrderOtherMenu[index]!.orderOtherPrice}"),
              ),
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
          return Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, int index) => Text("*** ${snapshot.data[index].cancelReason}",style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          );
        }
      }
    );
  }
}