import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:customer_by_dart/config/config.dart';
import 'package:customer_by_dart/customer/class/class_menu.dart';
import 'package:customer_by_dart/customer/class/class_menu_cart.dart';
import 'package:customer_by_dart/customer/class/class_user_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TypeDrink extends StatefulWidget{
  List<UserManager> userManager;
  int numberTable;
  final ValueSetter<MenuCart> _valueSetterAddMenu;
  TypeDrink(this.userManager,this.numberTable,this._valueSetterAddMenu);

  @override
  State<StatefulWidget> createState() => _TypeDrink(userManager,numberTable,_valueSetterAddMenu);
}

class _TypeDrink extends State<TypeDrink> {
  List<UserManager> userManager;
  int numberTable;
  final ValueSetter<MenuCart> _valueSetterAddMenu;
  _TypeDrink(this.userManager,this.numberTable,this._valueSetterAddMenu);

  //search_menu
  List<Menu> searchListMenu = [];
  int number = 1;

  String typeDrink = 'เครื่องดื่ม';
  String? _nameMenu;
  int? _priceMenu;
  int? valRadio;

  @override
  void initState() {
    super.initState();
    _getMenu(); /// initState function (getMenu).
    valRadio = 0; /// Can to setState((){});
  }

  Future<List<Menu>> _getMenu() async {
    var response = await http.get(Uri.parse("${Config.url}/menu/getMenu/${userManager[0].managerId}/$typeDrink"),headers: {'Accept': 'Application/json; charset=UTF-8'});
    var jsonData = jsonDecode(response.body);
    var data = jsonData['data'];
    List<Menu> listMenu = [];
    searchListMenu = listMenu;
    for (Map m in data) {
      if(m['statusSale']=="ขาย"){
        Menu lst = new Menu(m['menuId'],m['name'],m['priceMenuNormal'],m['priceMenuSpecial'],m['priceMenuPromotion'],m['typeMenu'],m['statusSale'],m['managerId'],number);
        listMenu.add(lst);
      }
      listMenu.sort((a,b) => a.menuId.compareTo(b.menuId));
    }
    return listMenu;
  }

  Future _getMenuImage(snapshot) async{
    var dataImage;
    await http.get(Uri.parse("${Config.url}/image/list/${snapshot.managerId}/${snapshot.menuId}/$typeDrink"),headers: {'Accept': 'Application/json; charset=UTF-8'}).then((response) {
      var jsonData = jsonDecode(response.body);
      dataImage = jsonData['data'];
    });
    return dataImage;
  }

  _selectMenu(index) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder( ///สำคัญมากๆ
            builder: (context,setState) {
              return AlertDialog(
                title: Text("${searchListMenu[index].name}", textAlign: TextAlign.center,
                ),
                content: SingleChildScrollView(
                  child: ListBody(
                      children: [
                        Center(
                          child: searchListMenu[index].priceMenuPromotion==0 /// if
                              ? Column(  ///true
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: valRadio == 0
                                      ? Text("*กรุณาเลือก พิเศษ หรือ ธรรมดา",style: TextStyle(color: Colors.redAccent),)
                                      : null,
                                    ),
                                    Center(
                                      child: searchListMenu[index].priceMenuNormal == 0
                                      ? null
                                      : ListTile(
                                        title: Text("ธรรมดา"),
                                        leading: Radio(
                                          value: 1,
                                          groupValue: valRadio,
                                          onChanged: (int? value0){
                                            setState((){
                                              valRadio = value0!;
                                              _nameMenu = "${searchListMenu[index].name} ธรรมดา";
                                              _priceMenu = searchListMenu[index].priceMenuNormal;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: searchListMenu[index].priceMenuSpecial == 0
                                      ? null
                                      : ListTile(
                                        title: Text("พิเศษ"),
                                        leading: Radio(
                                          value: 2,
                                          groupValue: valRadio,
                                          onChanged: (int? value1){
                                            setState((){
                                              valRadio = value1!;
                                              _nameMenu = "${searchListMenu[index].name} พิเศษ";
                                              _priceMenu = searchListMenu[index].priceMenuSpecial;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                              )
                              : Column( /// false
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: valRadio==0
                                          ? Text("*กรุณาเลือกโปรโมชั่น",style: TextStyle(color: Colors.redAccent),)
                                          : null,
                              ),
                                    Center(
                                      child: searchListMenu[index].priceMenuNormal==0 /// if
                                          ? null
                                          : ListTile(
                                              title: Text("โปรโมชั่น"),
                                              leading: Radio(
                                                value: 1,
                                                groupValue: valRadio,
                                                onChanged: (int? value0){
                                                  setState((){
                                                    valRadio = value0!;
                                                    _nameMenu = "${searchListMenu[index].name} โปรโมชั่น";
                                                    _priceMenu = searchListMenu[index].priceMenuPromotion;
                                                  });
                                                },
                                              ),
                                          ),
                                    ),
                                  ],
                              ), ///
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove_circle_outline,color: Colors.red),
                              iconSize: 40,
                              onPressed: (){
                                setState(() {
                                  number--;
                                  if(number < 1) {
                                    number = 1;
                                  }
                                });
                              },
                            ),
                            Text("$number",style: TextStyle(fontSize: 25)),
                            IconButton(
                              icon: Icon(Icons.add_circle_outline,color: Colors.green),
                              iconSize: 40,
                              onPressed: (){
                                setState(() {
                                  number++;
                                });
                              },
                            ),
                          ],
                        )
                    ]
                  ),
                ),
                actions: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: ElevatedButton(
                      child: Text("ยืนยัน"),
                      onPressed: () {
                        setState(() {
                          if(valRadio == 0){
                            valRadio = 0;
                          }else{
                            List<MenuCart> addListMenu = [];
                            for(int i=0; i<searchListMenu.length; i++){
                              MenuCart lst = new MenuCart(searchListMenu[index].menuId,_nameMenu!,_priceMenu!,searchListMenu[index].typeMenu,searchListMenu[index].managerId,number);
                              addListMenu.add(lst);
                            }
                            _valueSetterAddMenu(addListMenu[index]);
                            ScaffoldMessenger.of(context).showSnackBar(
                              new SnackBar(
                                duration: Duration(seconds: 1),
                                content: Text("เพิ่ม ${searchListMenu[index].name} จำนวน $number" + " ไปยังรถเข็นของคุณ",style: TextStyle(fontSize: 20),),
                              ),
                            );
                            number = 1;
                            valRadio = 0;
                            Navigator.pop(context);
                          }
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 100),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: ElevatedButton(
                      child: Text("ยกเลิก"),
                      onPressed: () {
                        setState(() {
                          number = 1;
                          valRadio = 0;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              );
            },
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            /*Card(
              color: Colors.white,
              child: Container(
                child: ListTile(
                  leading: Icon(Icons.search),
                  title: TextField(
                    decoration: InputDecoration(hintText: "Search menu", border: InputBorder.none,),
                    onChanged: (searchMenu){
                      setState(() {
                        searchListMenu = searchListMenu.where((value) => (value.name.toLowerCase().contains(searchMenu.toLowerCase()))).toList();
                      });
                    },
                  ),
                ),
              ),
            ),*/
            Expanded(
              /// FutureBuilder
              child: FutureBuilder(
                future: _getMenu(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.data == null) {
                    return Container(
                      child: Center(
                          child: CircularProgressIndicator()
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: searchListMenu.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: (){_selectMenu(index);},
                          child: Card(
                            elevation: 5,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                children: <Widget>[
                                  /// FutureBuilder
                                  FutureBuilder(
                                    future: _getMenuImage(searchListMenu[index]),
                                    builder: (BuildContext context,AsyncSnapshot snapshot){
                                      if(snapshot.data == null){
                                        return Container(
                                          height: 150,
                                          width: MediaQuery.of(context).size.width,
                                          child: Card(
                                            child: Icon(Icons.photo),
                                          ),
                                        );
                                      }else{
                                        /// Start for show picture by menu.
                                        List<dynamic> imageByMenu = [];
                                        for(var i in snapshot.data){
                                          imageByMenu.add(i);
                                        }
                                        /// End.
                                        /// Start Slide_Image.

                                        return CarouselSlider(
                                          options: CarouselOptions(height: 150,autoPlay: true),
                                          items: imageByMenu.map((e) {
                                            return Builder(
                                              builder: (BuildContext context) {
                                                return Container(
                                                    height: 150,
                                                    width: MediaQuery.of(context).size.width,
                                                    child: Card(
                                                        child: Image.memory(base64Decode(e),fit: BoxFit.fitWidth)
                                                    )
                                                );
                                              },
                                            );
                                          }).toList(),
                                        );
                                      }
                                    },
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: Text(
                                          searchListMenu[index].name,
                                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              child: searchListMenu[index].priceMenuNormal==0 /// if
                                                  ? null
                                                  : searchListMenu[index].priceMenuPromotion==0 /// if
                                                  ? Text("ธรรมดา ${searchListMenu[index].priceMenuNormal.toString()} บาท",
                                                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold,
                                                ),
                                              )
                                                  : Text("ธรรมดา ${searchListMenu[index].priceMenuNormal.toString()} บาท",
                                                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold,
                                                  decoration: TextDecoration.lineThrough,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 25),
                                            Container(
                                              child: searchListMenu[index].priceMenuSpecial==0 /// if
                                                  ? null
                                                  : searchListMenu[index].priceMenuPromotion==0 /// if
                                                  ? Text("พิเศษ ${searchListMenu[index].priceMenuSpecial.toString()} บาท",
                                                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold,
                                                ),
                                              )
                                                  : Text("พิเศษ ${searchListMenu[index].priceMenuSpecial.toString()} บาท",
                                                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold,
                                                  decoration: TextDecoration.lineThrough,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: snapshot.data[index].priceMenuSpecial==0 ?105 :25),
                                            Container(
                                              child: searchListMenu[index].priceMenuPromotion==0 ///if
                                                  ? null
                                                  : Text("โปรโมชั่น ${searchListMenu[index].priceMenuPromotion.toString()} บาท",
                                                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}