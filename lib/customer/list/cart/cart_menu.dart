import 'dart:convert';

import 'package:customer_by_dart/config/config.dart';
import 'package:customer_by_dart/customer/class/class_menu_cart.dart';
import 'package:customer_by_dart/customer/class/class_other_menu.dart';
import 'package:customer_by_dart/customer/class/class_user_manager.dart';
import 'package:customer_by_dart/customer/list/provider_method/provider_menu.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class CartMenu extends StatefulWidget {
  List<UserManager> userManager;
  int numberTable;
  CartMenu(this.userManager,this.numberTable);

  @override
  State<StatefulWidget> createState() => _CartMenu(userManager,numberTable);
}

class _CartMenu extends State<CartMenu> {
  List<UserManager> userManager;
  int numberTable;
  _CartMenu(this.userManager,this.numberTable);

  // var numberFormat = NumberFormat("#,##0.00"); /// Format price.
  var numberFormat = NumberFormat("#,###"); /// Format price.

  String makeStatus = "ยังไม่ส่ง"; /// create status is beginner send to backend.
  int tableCheckBillId = 0; /// create status is beginner send to backend.

  _showDialogBuyMenu(List<MenuCart> _cart) async{
    if(_cart.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        new SnackBar(
          content: Text("กรุณาเลือกรายการอาหาร!!"),
          duration: Duration(seconds: 1),
        ),
      );
    }else{
      String _statusInProgress = "กำลังดำเนินการ";
      String _statusAddImage = "เพิ่มสอบรูปภาพการโอนเงิน";
      String _statusCheckImage = "ตรวจสอบรูปภาพการโอนเงิน";
      String _statusEditImage = "แก้ไขรูปภาพการโอนเงิน";
      Map params = new Map();
      params['managerId'] = userManager[0].managerId.toString();
      params['numberTable'] = numberTable.toString();
      var response = await http.post(Uri.parse("${Config.url}/tableCheckBill/check/$_statusInProgress/$_statusAddImage/$_statusCheckImage/$_statusEditImage"),body: params,headers: {'Accept': 'Application/json; charset=UTF-8'});
      var jsonData = jsonDecode(response.body);
      if(jsonData['status'] == 1){
        ScaffoldMessenger.of(context).showSnackBar(
          new SnackBar(
            content: Text("เรียกชำระเงินไปแล้ว ไม่สามารถสั่งอาหารได้..!"),
            duration: Duration(seconds: 1),
          ),
        );
      }else{
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Center(
                  child: Text(
                    "ยืนยันการสั่งอาหาร",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: [
                      Center(child: Text("เมื่อกดยืนยันการสั่งอาหารไปแล้ว จะไม่สามารถแก้ไขรายการได้")),
                    ],
                  ),
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
                            onPressed: () => cartMenuToOrder(_cart),
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
                            onPressed: (){
                              Navigator.pop(context);
                            },
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
    }
  }

  cartMenuToOrder(_cart) async{
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      new SnackBar(
        content: Text("กำลังสั่งรายการอาหาร กรุณารอสักครู่..."),
        duration: Duration(seconds: 1),
      ),
    );
    /// Call api save (order_menu).
    Map params = new Map();
    for(int i=0; i<_cart.length; i++) {
      params['numberMenu'] = _cart[i].numberMenu.toString();
      params['numberTable'] = numberTable.toString();
      params['nameMenu'] = _cart[i].nameMenu.toString();
      params['priceMenu'] = _cart[i].priceMenu.toString();
      params['managerId'] = userManager[0].managerId.toString();
      params['makeStatus'] = makeStatus; /// กำหนด status เริ่มต้น = ยังไม่ส่ง;
      params['tableCheckBillId'] = tableCheckBillId.toString();
      var response = await http.post(Uri.parse("${Config.url}/order/saveOrder"),body: params,headers: {'Accept': 'Application/json; charset=UTF-8'});
      var jsonData = jsonDecode(response.body);
      var data = jsonData['data'];
      if(data != null){
        /// Call api save (order_other_menu).
        Map params = new Map();
        var _orderId = data['orderId'];
        await _cart[i].otherMenu.forEach((e) async{
          params['OrderOtherName'] = e.otherMenuName.toString();
          params['OrderOtherPrice'] = e.otherMenuPrice.toString();
          params['orderId'] = _orderId.toString();
          var response = await http.post(Uri.parse("${Config.url}/orderOtherMenu/save"),body: params,headers: {'Accept': 'Application/json; charset=UTF-8'});
        });
        if(i==(_cart.length-1)){
          ScaffoldMessenger.of(context).showSnackBar(
            new SnackBar(
              content: Text("สั่งอาหารเรียบร้อย"),
              duration: Duration(seconds: 1),
            ),
          );
          context.read<MenuProvider>().clearAllMenuFromCart(); /// Clear cart menu by Provider.
        }
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          new SnackBar(
            content: Text("กดสั่งอาหารอีกครั้ง..."),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  _showDialogRemoveMenu(MenuCart _cart) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: headerTextCenter("${_cart.nameMenu}"),
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
                    child: Text("ลบ"),
                    onPressed: () => _removeMenu(_cart),
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
      )
    );
  }

  _removeMenu(MenuCart _cart) {
    Navigator.pop(context);

    setState(() {
      String forCheckNameRemove = _cart.nameMenu;
      _cart.otherMenu.forEach((e) {
        forCheckNameRemove += "+${e.otherMenuName}";
      });
      context.read<MenuProvider>().removeMenuTFromCart(_cart,forCheckNameRemove); /// Send data by Provider.
    });
  }

  /// Widget.
  Text headerText(String string){
    return Text("$string",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),);
  }
  Text headerTextCenter(String string){
    return Text("$string",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),textAlign: TextAlign.center);
  }
  Text bodyText(String string){
    return Text("$string",style: TextStyle(fontSize: 14));
  }
  Text bodyPriceMenu(String string){
    return Text("$string",style: TextStyle(fontSize: 14),textAlign: TextAlign.center);
  }
  Text bodySumPrice(String string){
    return Text("${numberFormat.format(int.parse(string))}",style: TextStyle(fontSize: 14),textAlign: TextAlign.right);
  }
  Text bodyTotalPrice(String string){
    return Text("${numberFormat.format(int.parse(string))} บาท",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),);
  }

  @override
  Widget build(BuildContext context) {

    /// Call data from Provider(cart).
    List<MenuCart> _cart = context.watch<MenuProvider>().cartMenu;

    // TODO: implement build
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 5),
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Center(
                          child: Text("รายการที่เลือก : " + "โต๊ะ " + "$numberTable",style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold,color: Colors.black),)
                      )
                  ),
                ),
              ],
            ),
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
                      width: MediaQuery.of(context).size.width * 0.13,
                      child: headerTextCenter("ราคา"),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.22,
                      child: headerTextCenter("จำนวน"),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.15,
                      child: headerTextCenter("รวม"),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                ///itemCount: _cart.length,
                itemCount: _cart.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    color: Colors.grey[200],
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.38,
                                child: bodyText("${_cart[index].nameMenu}")
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.12,
                                child: bodyPriceMenu("${_cart[index].priceMenu}"),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.21,
                                child: Row(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.06,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(3),
                                        child: InkWell(
                                          onTap: () => context.read<MenuProvider>().addNumberToCart(index),
                                          child: Container(
                                            color: Colors.green,
                                            child: Icon(Icons.add,size: 25,color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.09,
                                      child: Center(
                                        child: Align(
                                            alignment: Alignment.center,
                                            child: Text("${_cart[index].numberMenu}",textAlign: TextAlign.right)
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.06,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(3),
                                        child: InkWell(
                                          onTap: () => context.read<MenuProvider>().removeNumberToCart(index),
                                          child: Container(
                                            color: Colors.orange,
                                            child: Icon(Icons.remove,size: 25,color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.14,
                                child: bodySumPrice("${(_cart[index].priceMenu * _cart[index].numberMenu) + (_cart[index].otherMenu.length == 0 ?0 :_cart[index].otherMenu.map((e) => e.otherMenuPrice * _cart[index].numberMenu).reduce((value, element) => value + element))}"),
                              ),
                            ],
                          ),
                          subtitle: Container(
                            child: _cart[index].otherMenu.length == 0
                                ? null
                                : ListViewBuilderForCartMenu(_cart[index].otherMenu),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.09,
                          child: InkWell(
                            child: Icon(Icons.delete_forever,color: Colors.red),
                            onTap:  () => _showDialogRemoveMenu(_cart[index]),
                          ),
                        ),
                      ],
                    )
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
                            child: _cart.length <= 0
                                ? bodyTotalPrice("${0}")
                                : bodyTotalPrice("${_cart.map((cart) => cart.numberMenu * cart.priceMenu + (cart.otherMenu.length == 0 ?0 :cart.otherMenu.map((e) => e.otherMenuPrice * cart.numberMenu).reduce((value, element) => value + element))).reduce((value, element) => value + element)}"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8,right: 8),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green[600]
                          // shape: RoundedRectangleBorder(
                          //   borderRadius: BorderRadius.circular(10),
                          // ),
                        ),
                        child: Text("สั่งซื้อ",style: TextStyle(fontSize: 18)),
                        onPressed: () => _showDialogBuyMenu(_cart),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Create for listview.builder (other_menu).
class ListViewBuilderForCartMenu extends StatelessWidget {
  List<OtherMenu?> otherMenu;
  ListViewBuilderForCartMenu(this.otherMenu);

  /// Widget.
  // Text headerText(String string){
  //   return Text("$string",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),);
  // }
  Text bodyText(String string){
    return Text("$string",style: TextStyle(fontSize: 14),);
  }
  Text bodyPrice(String string){
    return Text("$string",style: TextStyle(fontSize: 16),textAlign: TextAlign.center);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: otherMenu.length,
      itemBuilder: (BuildContext context, int index) => Column(
        children: [
          Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                child: bodyText("+${otherMenu[index]!.otherMenuName}"),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.125,
                child: bodyPrice("${otherMenu[index]!.otherMenuPrice}"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}