import 'dart:convert';
import 'dart:io';

import 'package:customer_by_dart/config/config.dart';
import 'package:customer_by_dart/customer/class/class_cancel_order_menu.dart';
import 'package:customer_by_dart/customer/class/class_image_slip_transfer.dart';
import 'package:customer_by_dart/customer/class/class_order.dart';
import 'package:customer_by_dart/customer/class/class_order_other_menu.dart';
import 'package:customer_by_dart/customer/class/class_table_check_bill.dart';
import 'package:customer_by_dart/customer/class/class_user_manager.dart';
import 'package:customer_by_dart/customer/list/paytransfer/edit_pay_transfer.dart';
import 'package:customer_by_dart/customer/list/paytransfer/pay_transfer.dart';
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

  int statusInProgress = 0;
  int statusCheckImageSlip = 0;
  int statusAddImageSlip = 0;
  int statusEditImageSlip = 0;
  TableCheckBill? tableCheckBill;

  List<ListOrder> _listOrderByCheckStatusForShowTotalPrice = [];
  List<ListOrder> _listOrder = [];
  List<ListOrderMakeStatus> _listMakeStatus = [];

  int tableCheckBillId = 0;
  int? _priceTotal;

  @override
  void initState(){
    super.initState();
    _getOrder();
    _getTableCheckBillInProgress();
    _getTableCheckBillCheckImageSlip();
    _getTableCheckByAddImageSlip();
    _getTableCheckByEditImageSlip();
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
    List<ListOrder> listOrderByCheckStatusForShowTotalPrice = [];/// For check_status == "?????????????????????" && "???????????????????????????".
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

      /// For check_status == "?????????????????????" && "???????????????????????????". ???????????????????????????????????????????????????????????? total.
      if(o['makeStatus']=="?????????????????????" || o['makeStatus']=="???????????????????????????"){
        ListOrder lstOrder = new ListOrder(o['orderId'], o['numberMenu'], o['numberTable'], o['nameMenu'], o['priceMenu'], o['managerId'], o['makeStatus'], o['tableCheckBillId'],listOrderOtherMenu);
        listOrderByCheckStatusForShowTotalPrice.add(lstOrder);
        checkPassAndNotSent.add(lstOrder); ///---
      }
      /// For check_status == "??????????????????".
      if(o['makeStatus']=="??????????????????"){
        ListOrder lstOrder = new ListOrder(o['orderId'], o['numberMenu'], o['numberTable'], o['nameMenu'], o['priceMenu'], o['managerId'], o['makeStatus'], o['tableCheckBillId'],listOrderOtherMenu);
        checkCancel.add(lstOrder); ///---
      }

      /// Class name this page.
      if(o['makeStatus']=="?????????????????????" || o['makeStatus']=="??????????????????") {
        ListOrderMakeStatus listOrderMakeStatus = new ListOrderMakeStatus(o['makeStatus']);
        listMakeStatus.add(listOrderMakeStatus);
      }
    }

    /// ???????????????????????????????????????????????? ????????????????????? "?????????????????????" && "???????????????????????????".
    checkPassAndNotSent.sort((a,b) => a.orderId.compareTo(b.orderId));
    checkPassAndNotSent.forEach((passAndNotSent) {
      listOrder.add(passAndNotSent);
    });
    /// ???????????????????????????????????????????????? ????????????????????? "??????????????????".
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

    return _listOrder;
  }

  /// ??????????????? => ??????????????????????????????????????????.
  Future _getTableCheckBillInProgress() async{
    String _paymentStatus = "??????????????????????????????????????????"; /// ??????????????????????????????????????????.
    Map params = new Map();
    params['managerId'] = userManager[0].managerId.toString();
    params['numberTable'] = numberTable.toString();
    var response = await http.post(Uri.parse("${Config.url}/tableCheckBill/check/$_paymentStatus"),body: params,headers: {'Accept': 'Application/json; charset=UTF-8'});
    var jsonData = jsonDecode(response.body);
    if(jsonData['status'] == 1){
      statusInProgress = 0;
      statusInProgress = jsonData['status'];
    }else{
      statusInProgress = 0;
    }
    return statusInProgress;
  }

  /// ??????????????? => ?????????????????????????????????????????????????????????????????????.
  Future _getTableCheckBillCheckImageSlip() async{
    String _paymentStatus = "?????????????????????????????????????????????????????????????????????"; /// ??????????????????????????????????????????.
    Map params = new Map();
    params['managerId'] = userManager[0].managerId.toString();
    params['numberTable'] = numberTable.toString();
    var response = await http.post(Uri.parse("${Config.url}/tableCheckBill/check/$_paymentStatus"),body: params,headers: {'Accept': 'Application/json; charset=UTF-8'});
    var jsonData = jsonDecode(response.body);
    if(jsonData['status'] == 1){
      statusCheckImageSlip = 0;
      statusCheckImageSlip = jsonData['status'];
    }else{
      statusCheckImageSlip = 0;
    }
    return statusCheckImageSlip;
  }

  /// ??????????????? => ???????????????????????????????????????????????????????????????.
  Future _getTableCheckByAddImageSlip() async{
    String _paymentStatus = "???????????????????????????????????????????????????????????????"; /// ??????????????????????????????????????????.
    Map params = new Map();
    params['managerId'] = userManager[0].managerId.toString();
    params['numberTable'] = numberTable.toString();
    var response = await http.post(Uri.parse("${Config.url}/tableCheckBill/check/$_paymentStatus"),body: params,headers: {'Accept': 'Application/json; charset=UTF-8'});
    var jsonData = jsonDecode(response.body);
    var data = jsonData['data'];
    if(jsonData['status'] == 1){
      statusAddImageSlip = 0;
      statusAddImageSlip = jsonData['status'];
      tableCheckBill = new TableCheckBill(data['tableCheckBillId'], data['managerId'], data['numberTable'], data['paymentType'], data['paymentStatus'], data['priceTotal'], data['date'], data['time'], []);
    }else{
      statusAddImageSlip = 0;
    }
    return tableCheckBill;
  }

  /// ??????????????? => ?????????????????????????????????????????????????????????.
  Future _getTableCheckByEditImageSlip() async{
    String _paymentStatus = "???????????????????????????????????????????????????????????????"; /// ??????????????????????????????????????????.
    Map params = new Map();
    params['managerId'] = userManager[0].managerId.toString();
    params['numberTable'] = numberTable.toString();
    var response = await http.post(Uri.parse("${Config.url}/tableCheckBill/check/$_paymentStatus"),body: params,headers: {'Accept': 'Application/json; charset=UTF-8'});
    var jsonData = jsonDecode(response.body);
    var status = jsonData['status'];
    var data = jsonData['data'];
    if(jsonData['status'] == 1){
      statusEditImageSlip = 0;
      statusEditImageSlip = status;
      ///
      List<ImageSlipTransfer> imageSlipTransfer = [];
      var responseImage = await http.get(Uri.parse("${Config.url}/imageSlipTransfer/list/${data['tableCheckBillId']}"),headers: {'Accept': 'Application/json; charset=UTF-8'});
      var jsonDataImage = jsonDecode(responseImage.body);
      var dataImage = jsonDataImage['data'];
      for(var d in dataImage){
        var img = base64Decode(d['imageSlip']);
        ImageSlipTransfer imgSlip = new ImageSlipTransfer(d['imageSlipId'], d['nameTransfer'], d['telTransfer'], d['tableCheckBillId'], img);
        imageSlipTransfer.add(imgSlip);
      }
      tableCheckBill = new TableCheckBill(data['tableCheckBillId'], data['managerId'], data['numberTable'], data['paymentType'], data['paymentStatus'], data['priceTotal'], data['date'], data['time'], imageSlipTransfer);
    }else{
      statusEditImageSlip = 0;
    }
    return tableCheckBill;
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
  //     if(o['makeStatus']=="?????????????????????????????????") {
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
      if(_listOrder.length == _listMakeStatus.length){
        String _paymentStatus = "??????????????????????????????????????????";
        Map params = new Map();
        params['managerId'] = userManager[0].managerId.toString();
        params['numberTable'] = numberTable.toString();
        var response = await http.post(Uri.parse("${Config.url}/tableCheckBill/check/$_paymentStatus"),body: params,headers: {'Accept': 'Application/json; charset=UTF-8'});
        var jsonData = jsonDecode(response.body);
        if(jsonData['status'] == 1){
          ScaffoldMessenger.of(context).showSnackBar(
            new SnackBar(
              content: Text("????????????????????????????????????????????????????????? ???????????????????????????????????????.."),
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
                          child: Text("??????????????????????????????????????????"),
                        ),
                        onTap: () => _checkBillDialogTransfer(),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: Center(
                          child: Text("??????????????????????????????????????????"),
                        ),
                        onTap: () => _checkBillDialog(),
                      ),
                    ),
                    Card(
                      color: Colors.red[300],
                      child: ListTile(
                        title: Center(
                          child: Text("????????????????????????"),
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
              content: Text("???????????????????????????????????????????????????????????????????????? ?????????????????????????????????????????????"),
              duration: Duration(seconds: 1),
            )
        );
      }
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        new SnackBar(
          content: Text("??????????????????????????????????????????????????????????????????..!"),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  _showDialogPriceZero(){
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Text("?????????????????????????????????????????????????????????????????? ????????????????????????????????????????????????????????????????????????????????????",textAlign: TextAlign.center),
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
                    child: Text("??????????????????"),
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
                    child: Text("????????????????????????"),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// _Price_Total = 0;
  /// ??????????????????????????????????????? "??????????????????"
  _priceTotalIsZero() async{
    Navigator.of(context).pop();

    String _paymentType = "??????????????????";
    String _paymentStatus = "??????????????????";
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
                  content: Text("?????????????????????????????????????????????????????????"),
                  duration: Duration(seconds: 1),
                )
            );
          });
        }
      }
    });
  }

  _checkBillDialogTransfer() {
    Navigator.pop(context);
    return showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("?????????????????????????????????????????????",textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold),),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("??????????????? : $_priceTotal ?????????",textAlign: TextAlign.center,style: TextStyle(fontSize: 25,color: Colors.blue),),
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
                        child: Text("??????????????????"),
                        onPressed: () => _checkBillTransfer(),
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
                          child: Text("????????????????????????"),
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

  _checkBillTransfer() async{
    Navigator.of(context).pop();

    String _paymentType = "?????????????????????????????????????????????";
    String _paymentStatus = "??????????????????????????????????????????";
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
          _getTableCheckBillInProgress();
          _getTableCheckByAddImageSlip();
          _getTableCheckByEditImageSlip();
          _getTableCheckBillCheckImageSlip();
        });
        ScaffoldMessenger.of(context).showSnackBar(
            new SnackBar(
              content: Text("???????????????????????????????????????????????????"),
              duration: Duration(seconds: 1),
            )
        );
      }
    });
  }

  _checkBillDialog() {
    Navigator.pop(context);
    return showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("??????????????????????????????????????????",textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold),),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("??????????????? : $_priceTotal ?????????",textAlign: TextAlign.center,style: TextStyle(fontSize: 25,color: Colors.blue),),
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
                        child: Text("??????????????????"),
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
                        child: Text("????????????????????????"),
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

    String _paymentType = "??????????????????????????????????????????";
    String _paymentStatus = "??????????????????????????????????????????";
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
          _getTableCheckBillInProgress();
          _getTableCheckByAddImageSlip();
          _getTableCheckByEditImageSlip();
          _getTableCheckBillCheckImageSlip();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          new SnackBar(
            content: Text("???????????????????????????????????????????????????"),
            duration: Duration(seconds: 1),
          )
        );
      }
    });
  }

  Future<void> _refreshFuture() async{
    setState(() {
      _getOrder();
      _getTableCheckBillInProgress();
      _getTableCheckByAddImageSlip();
      _getTableCheckByEditImageSlip();
      _getTableCheckBillCheckImageSlip();
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
    return Text("${numberFormat.format(int.parse(string))} ?????????",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: SafeArea(
        child: Card(
          color: Colors.white,
          child: RefreshIndicator(
            onRefresh: () => _refreshFuture(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    // color: Colors.grey[500],
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Text("??????????????????????????????????????? : " + "???????????? " + "$numberTable", style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold,color: Colors.black),
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
                                      child: headerText("????????????")
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.14,
                                      child: headerCenter("????????????"),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.18,
                                      child: headerCenter("???????????????"),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.14,
                                      child: headerCenter("?????????"),
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
                                        child: snapshot.data[index].makeStatus == "?????????????????????" /// Status condition
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
                                                    child: Text("??????????????????",style: TextStyle(color: Colors.green[600],fontWeight: FontWeight.bold)),
                                                  ),
                                                ),
                                              ],
                                            )
                                            : snapshot.data[index].makeStatus == "???????????????????????????"
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
                                                            Text("??????",style: TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.right),
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
                                                : Container( /// "??????????????????"
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
                                                          child: Text("??????????????????",style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),textAlign: TextAlign.right),
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
                                          Text("?????????????????????????????? :",style: TextStyle(fontSize: 18),),
                                          Container(
                                            child: _priceTotal == 0
                                                ? bodyTotalPrice("${0}")
                                                : bodyTotalPrice("$_priceTotal"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8,right: 8),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width * 0.7,
                                      child: statusInProgress == 1 /// ??????????????? => ??????????????????????????????????????????.
                                          ? ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                primary: Colors.red[300],
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.refresh),
                                                  Text("????????????????????????????????????????????????..."),
                                                ],
                                              ),
                                              onPressed: () => setState(() {
                                                _getTableCheckByAddImageSlip();
                                                _getTableCheckBillCheckImageSlip();
                                                _getTableCheckByEditImageSlip();
                                                _getTableCheckBillInProgress();
                                              }),
                                            )
                                          : statusAddImageSlip == 1 /// ??????????????? => ???????????????????????????????????????????????????????????????.
                                              ? ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    primary: Colors.lightGreen,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.add),
                                                      Text("???????????????????????????????????????????????????????????????"),
                                                    ],
                                                  ),
                                                  onPressed: () => setState(() {
                                                    _getTableCheckByEditImageSlip();
                                                    _getTableCheckBillCheckImageSlip();
                                                    _getTableCheckBillInProgress();
                                                    _getTableCheckByAddImageSlip().then((value){
                                                      if(value != null){
                                                        Navigator.push(context, MaterialPageRoute(builder: (context) => PayByTransfer(value))).then((value) => setState((){_getTableCheckByAddImageSlip();_getTableCheckBillCheckImageSlip();_getTableCheckByEditImageSlip();_getTableCheckBillInProgress();}));
                                                      }
                                                    });
                                                  }),
                                                )
                                              : statusEditImageSlip == 1 /// ??????????????? => ???????????????????????????????????????????????????????????????.
                                                  ? ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                        primary: Colors.amber[500],
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(Icons.edit),
                                                          Text("???????????????????????????????????????????????????????????????"),
                                                        ],
                                                      ),
                                                      onPressed: () => setState(() {
                                                        _getTableCheckBillInProgress();
                                                        _getTableCheckBillCheckImageSlip();
                                                        _getTableCheckByAddImageSlip();
                                                        _getTableCheckByEditImageSlip().then((value){
                                                          if(value != null){
                                                            Navigator.push(context, MaterialPageRoute(builder: (context) => EditPayTransfer(value))).then((value) => setState((){_getTableCheckByAddImageSlip();_getTableCheckBillCheckImageSlip();_getTableCheckByEditImageSlip();_getTableCheckBillInProgress();}));
                                                          }
                                                        });
                                                      }),
                                                    )
                                                  : statusCheckImageSlip == 1 ///??????????????? => ??????????????????????????????????????????????????????????????????.
                                                      ? ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            primary: Colors.red[300],
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Icon(Icons.refresh),
                                                              Text("???????????????????????????????????????????????????????????????"),
                                                            ],
                                                          ),
                                                          onPressed: () => setState(() {
                                                            _getTableCheckByAddImageSlip();
                                                            _getTableCheckBillCheckImageSlip();
                                                            _getTableCheckByEditImageSlip();
                                                            _getTableCheckBillInProgress();
                                                          }),
                                                        )
                                                      : _priceTotal == 0 && _listOrder.length > 0 ///??????????????? => ??????????????????????????????????????? (??????????????????????????????).
                                                           ? ElevatedButton( /// ???????????????????????????????????????????????????
                                                               style: ElevatedButton.styleFrom(
                                                                 primary: Colors.green[600],
                                                               ),
                                                               child: Text("??????????????????",style: TextStyle(fontSize: 18)),
                                                               onPressed: () => setState(() {
                                                                 _getTableCheckByEditImageSlip();
                                                                 _getTableCheckBillCheckImageSlip();
                                                                 _getTableCheckByAddImageSlip();
                                                                 _getTableCheckBillInProgress();
                                                                 _getOrder();
                                                                 _showDialogPriceZero();
                                                               }),
                                                             )
                                                           : ElevatedButton( /// ???????????????????????????????????????????????????
                                                               style: ElevatedButton.styleFrom(
                                                                 primary: Colors.green[600],
                                                               ),
                                                               child: Text("????????????????????????",style: TextStyle(fontSize: 18)),
                                                               onPressed: () => setState(() {
                                                                 _getTableCheckByEditImageSlip();
                                                                 _getTableCheckBillCheckImageSlip();
                                                                 _getTableCheckByAddImageSlip();
                                                                 _getTableCheckBillInProgress();
                                                                 _getOrder();
                                                                 _onCallCheckBill();
                                                               }),
                                                             ),
                                    ),
                                  ),
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


/// Create for listview.builder (cancel_order_menu) ???????????????????????????????????????????????????????????????.
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