import 'dart:convert';
import 'dart:io';

import 'package:customer_by_dart/config/config.dart';
import 'package:customer_by_dart/customer/class/class_menu_cart.dart';
import 'package:customer_by_dart/customer/class/class_user_manager.dart';
import 'package:customer_by_dart/customer/list/provider_method/provider_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  String makeStatus = "กำลังทำ"; /// create status is beginner send to backend.

  cartMenuToOrder(_cart) async{
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      new SnackBar(
        content: Text("กำลังสั่งรายการอาหาร กรุณารอสักครู่..."),
      ),
    );
    Map params = new Map();
    for(int i=0; i<_cart.length; i++) {
      params['numberMenu'] = _cart[i].numberMenu.toString();
      params['numberTable'] = numberTable.toString();
      params['nameMenu'] = _cart[i].nameMenu.toString();
      params['priceMenu'] = _cart[i].priceMenu.toString();
      params['managerId'] = userManager[0].managerId.toString();
      params['makeStatus'] = makeStatus; /// Set value in backend = กำลังทำ;
      await http.post(Uri.parse("${Config.url}/order/saveOrder"),body: params,headers: {'Accept' : 'Application/json; charset=UTF-8'}).then((response) {
        print(response.body);
        var jsonData = jsonDecode(response.body);
        var status = jsonData['status'];
        if(status==1){
          if(i==(_cart.length-1)){
            ScaffoldMessenger.of(context).showSnackBar(
              new SnackBar(
                content: Text("สั่งอาหารเรียบร้อย"),
              ),
            );
            setState(() {
              context.read<MenuProvider>().clearAllMenuFromCart(); /// Clear cart menu by Provider.
              ///_cart.removeRange(0, _cart.length); /// reset value in (_cart) Arrays at start[0] to end[...length]
            });
          }
        }else{
          ScaffoldMessenger.of(context).showSnackBar(
            new SnackBar(
              content: Text("กดสั่งอาหารอีกครั้ง..."),
            ),
          );
          Navigator.pop(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    List<MenuCart> _cart = context.watch<MenuProvider>().cart; /// Call data from Provider(cart).

    // TODO: implement build
    return Scaffold(
      body: SafeArea(
        child: Card(
          color: Colors.red[100],
          child: Column(
            children: <Widget>[
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: (){
                      Navigator.of(context).pop();
                      },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                            width: 300,
                            color: Colors.red[300],
                            child: Center(
                                child: Text("รายการที่เลือก : " + "โต๊ะ " + "$numberTable",
                                  style: TextStyle(fontSize: 25, color: Colors.white),
                                )
                            )
                        )
                    ),
                  ),
                ],
              ),
              Container(
                height: 50,
                color: Colors.amber,
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("เมนู",style: TextStyle(fontSize: 20),),
                      Text("จำนวน",style: TextStyle(fontSize: 20),),
                    ],
                  ),
                  trailing: SizedBox(width: 30,),
                ),
              ),
              SizedBox(height: 8,),
              Expanded(
                child: ListView.builder(
                  ///itemCount: _cart.length,
                  itemCount: _cart.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      color: Colors.white,
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${_cart[index].nameMenu}"),
                            Text("${_cart[index].numberMenu}"),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.clear),
                          color: Colors.red,
                          splashColor: Colors.green,
                          onPressed: () {
                            setState(() {
                              context.read<MenuProvider>().removeMenuTFromCart(_cart[index]); /// Send data by Provider.
                            });
                          },
                        ),
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
                          color: Colors.yellowAccent,
                          child: ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("ราคารวม :",style: TextStyle(fontSize: 20),),
                                Text("${_cart.length > 0 ? _cart.map((cart) => cart.priceMenu * cart.numberMenu).reduce((value, element) => value + element) : 0}" + " บาท",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                              ],
                            ),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text("สั่งอาหาร",style: TextStyle(fontSize: 18)),
                        onPressed: (){
                          if(_cart.isEmpty){
                            ScaffoldMessenger.of(context).showSnackBar(
                              new SnackBar(
                                content: Text("กรุณาเลือกรายการอาหาร!!"),
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
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: ElevatedButton(
                                          child: Text("ยืนยัน"),
                                          onPressed: () => cartMenuToOrder(_cart),
                                        ),
                                      ),
                                      SizedBox(width: 100),
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: ElevatedButton(
                                          child: Text("ยกเลิก"),
                                          onPressed: (){
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                }
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}