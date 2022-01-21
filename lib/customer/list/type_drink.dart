import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:customer_by_dart/config/config.dart';
import 'package:customer_by_dart/customer/class/class_category_menu.dart';
import 'package:customer_by_dart/customer/class/class_menu.dart';
import 'package:customer_by_dart/customer/class/class_menu_cart.dart';
import 'package:customer_by_dart/customer/class/class_other_menu.dart';
import 'package:customer_by_dart/customer/class/class_user_manager.dart';
import 'package:customer_by_dart/customer/list/provider_method/provider_menu.dart';
import 'package:customer_by_dart/customer/list/search_food_drink.dart';
import 'package:customer_by_dart/customer/list/state/check_dialog_typefood_typedrink.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class TypeDrink extends StatefulWidget{
  List<UserManager> userManager;
  int numberTable;
  TypeDrink(this.userManager,this.numberTable);

  @override
  State<StatefulWidget> createState() => _TypeDrink(userManager,numberTable);
}

class _TypeDrink extends State<TypeDrink> with AutomaticKeepAliveClientMixin {
  List<UserManager> userManager;
  int numberTable;
  _TypeDrink(this.userManager,this.numberTable);

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true; /// ไม่ต้องรีเฟรซหน้าใหม่เมื่อเปลี่ยน TabBar. And add (with AutomaticKeepAliveClientMixin) behind Class.

  //search_menu
  // List<Menu> _searchListMenu = [];
  List<Menu> _showListMenu = [];
  int number = 1;

  String typeFood = "เครื่องดื่ม";
  String? _nameMenu;
  int? _priceMenu;
  int? valRadio;

  List<OtherMenu> _otherMenu = []; /// Add other_menu to cart.

  @override
  void initState() {
    super.initState();
    _getMenu();

    /// initState function (getMenu).
    valRadio = 0;

    /// Can to setState((){});
  }

  Future<List<Menu>> _getMenu() async {
    var response = await http.get(Uri.parse("${Config.url}/menu/getMenu/${userManager[0].managerId}/$typeFood"), headers: {'Accept': 'Application/json; charset=UTF-8'});
    var jsonData = jsonDecode(response.body);
    var data = jsonData['data'];
    List<Menu> listMenuSale = [];
    List<Menu> listMenuNotSale = [];
    List<Menu> listMenu = [];
    for (Map m in data) {
      if (m['statusSale'] == "ขาย") {
        Menu lst = new Menu(m['menuId'], m['categoryMenu'], m['name'], m['priceMenuNormal'], m['priceMenuSpecial'], m['priceMenuPromotion'], m['typeMenu'], m['statusSale'], m['managerId'], number);
        listMenuSale.add(lst);
      }else {
        Menu lst = new Menu(m['menuId'], m['categoryMenu'], m['name'], m['priceMenuNormal'], m['priceMenuSpecial'], m['priceMenuPromotion'], m['typeMenu'], m['statusSale'], m['managerId'], number);
        listMenuNotSale.add(lst);
      }
    }

    /// Not_Sale.
    listMenuNotSale.sort((a, b) => a.menuId.compareTo(b.menuId));
    listMenuNotSale.forEach((notSale) {
      listMenu.add(notSale);
    });

    /// Sale.
    listMenuSale.sort((a, b) => a.menuId.compareTo(b.menuId));
    listMenuSale.forEach((sale) {
      listMenu.add(sale);
    });
    _showListMenu = listMenu.reversed.toList();
    return _showListMenu;
  }

  Future _getMenuImage(snapshot) async {
    var dataImage;
    await http.get(Uri.parse("${Config.url}/image/list/${snapshot.managerId}/${snapshot.menuId}/$typeFood"), headers: {'Accept': 'Application/json; charset=UTF-8'}).then((response) {
      var jsonData = jsonDecode(response.body);
      dataImage = jsonData['data'];
    });
    return dataImage;
  }

  /// CheckBox Category.
  List<String> _valueFromCheckbox = [];
  /// list (category_menu) AND (other_menu).
  Future _getCategoryAndOtherMenu(Menu searchListMenu) async {
    List<OtherMenu> listOtherMenu = [];
    List<CategoryMenu> listCategoryMenu = [];

    /// Call api (category_menu).
    var responseCategoryMenu = await http.get(Uri.parse("${Config.url}/categoryMenu/list/${searchListMenu.managerId}/${searchListMenu.categoryName}"), headers: {'Accept': 'Application/json; charset=UTF-8'});
    var jsonDataCategoryMenu = jsonDecode(responseCategoryMenu.body);
    var dataCategoryMenu = jsonDataCategoryMenu['data'];
    for (Map c in dataCategoryMenu) {
      CategoryMenu list = new CategoryMenu(c['categoryMenuId'], c['categoryMenuName'], c['otherMenuId'], c['managerId']);
      listCategoryMenu.add(list);

      /// Call api (other_menu).
      var responseOtherMenu = await http.get(Uri.parse('${Config.url}/otherMenu/list/${list.otherMenuId}'), headers: {'Accept': 'Application/json; charset=UTF-8'});
      var jsonDataOtherMenu = jsonDecode(responseOtherMenu.body);
      var dataOtherMenu = jsonDataOtherMenu['data'];
      OtherMenu otherMenu = new OtherMenu(dataOtherMenu['otherMenuId'], dataOtherMenu['otherMenuName'], dataOtherMenu['otherMenuPrice'], dataOtherMenu['managerId'], dataOtherMenu['typeMenu']);
      listOtherMenu.add(otherMenu);
    }
    return listOtherMenu;
  }

  ///Show Dialog select_menu by index.
  _selectMenuToAlertDialog(index) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(///สำคัญมากๆ
            builder: (BuildContext context, setState) {
              return AlertDialog(
                title: Text("${_showListMenu[index].name}",
                    textAlign: TextAlign.center),
                content: SingleChildScrollView(
                    child: Column(
                        children: [
                          /// Special or Normal or Promotion.
                          Center(
                            child: _showListMenu[index].priceMenuPromotion == 0 /// if
                                ? Column( ///true
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: valRadio == 0
                                      ? Text("*กรุณาเลือก พิเศษ หรือ ธรรมดา", style: TextStyle(color: Colors.redAccent),)
                                      : Text("กรุณาเลือก พิเศษ หรือ ธรรมดา"),
                                ),
                                Center(
                                  child: _showListMenu[index].priceMenuNormal == 0
                                      ? null
                                      : ListTile(
                                    title: Text("ธรรมดา"),
                                    leading: Radio(
                                      value: 1,
                                      groupValue: valRadio,
                                      onChanged: (int? value0) {
                                        setState(() {
                                          valRadio = value0!;
                                          _nameMenu = "${_showListMenu[index].name} (ธรรมดา)";
                                          _priceMenu = _showListMenu[index].priceMenuNormal;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                Center(
                                  child: _showListMenu[index].priceMenuSpecial == 0
                                      ? null
                                      : ListTile(
                                    title: Text("พิเศษ"),
                                    leading: Radio(
                                      value: 2,
                                      groupValue: valRadio,
                                      onChanged: (int? value1) {
                                        setState(() {
                                          valRadio = value1!;
                                          _nameMenu = "${_showListMenu[index].name} (พิเศษ)";
                                          _priceMenu =  _showListMenu[index].priceMenuSpecial;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            )
                                : Column( ///else.
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: valRadio == 0
                                      ? Text("*กรุณาเลือกโปรโมชั่น", style: TextStyle(color: Colors.redAccent),)
                                      : Text("กรุณาเลือกโปรโมชั่น"),
                                ),
                                Center(
                                  child: _showListMenu[index].priceMenuNormal == 0
                                      ? null
                                      : ListTile(
                                    title: Text("โปรโมชั่น"),
                                    leading: Radio(
                                      value: 1,
                                      groupValue: valRadio,
                                      onChanged: (int? value0) {
                                        setState(() {
                                          valRadio = value0!;
                                          _nameMenu = "${_showListMenu[index].name} (โปรโมชั่น)";
                                          _priceMenu = _showListMenu[index].priceMenuPromotion;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FutureBuilder(
                              future: _getCategoryAndOtherMenu(_showListMenu[index]),
                              builder: (BuildContext context, AsyncSnapshot snapShot) {
                                if (snapShot.data == null || snapShot.data.length == 0) {
                                  return Center(
                                    //child: CircularProgressIndicator(),
                                    child: null,
                                  );
                                }else {
                                  return CheckBoxOnDialogTypeFoodAndTypeDrink(
                                    snapShot.data,
                                        (addOtherMenu) => setState(() => _otherMenu.add(addOtherMenu)),
                                        (removeOtherMenu) => setState(() => _otherMenu.remove(removeOtherMenu)),
                                  ); /// Check_Box.
                                }
                              }
                          ),
                          /// Icon_Button add number.
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove_circle_outline,color: Colors.red),
                                iconSize: 40,
                                onPressed: () {
                                  setState(() {
                                    number--;
                                    if (number < 1) {
                                      number = 1;
                                    }
                                  });
                                },
                              ),
                              Text("$number", style: TextStyle(fontSize: 25)),
                              IconButton(
                                icon: Icon(Icons.add_circle_outline,color: Colors.green),
                                iconSize: 40,
                                onPressed: () {
                                  setState(() {
                                    number++;
                                  });
                                },
                              ),
                            ],
                          )
                        ]
                    )
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        child: Text("ยืนยัน"),
                        onPressed: () => _buttonSelectMenu(index),
                      ),
                      ElevatedButton(
                        child: Text("ยกเลิก"),
                        onPressed: () {
                          number = 1;
                          valRadio = 0;
                          _otherMenu = [];
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        });
  }

  /// Button select_menu.
  _buttonSelectMenu(index) {
    if (valRadio == 0) {
      valRadio = 0;
    }else { /// ทำในนี้
      List<MenuCart> addListMenu = [];
      String forCheckName = _nameMenu!;
      for (int i=0; i<_showListMenu.length; i++) {
        MenuCart lst = new MenuCart(_showListMenu[index].menuId, _nameMenu!, _priceMenu!, _showListMenu[index].typeMenu, _showListMenu[index].managerId, number, _otherMenu);
        addListMenu.add(lst);
      }
      _otherMenu.forEach((e) {
        forCheckName += "+${e.otherMenuName}";
      });
      /// Add cart menu by Provider.
      context.read<MenuProvider>().addMenuToCart(addListMenu[index],forCheckName);
      ScaffoldMessenger.of(context).showSnackBar(
        new SnackBar(
          content: Text("เพิ่ม ${_showListMenu[index].name} จำนวน $number" + " ไปยังรถเข็นของคุณ"),
          duration: Duration(seconds: 1),
        ),
      );
      number = 1;
      valRadio = 0;
      _otherMenu = [];
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                future: _getMenu(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.data == null) {
                    return Container(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }else {
                    return ListView.builder(
                      itemCount: _showListMenu.length,
                      itemBuilder: (BuildContext context, int index) => Container(
                          child: _showListMenu[index].statusSale == "ขาย"
                              ? GestureDetector(/// If => (true = ขาย)
                            onTap: () => _selectMenuToAlertDialog(index),
                            /// SELECT MENU.
                            child: Card(
                                elevation: 5,
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                    children: <Widget>[
                                      /// FutureBuilder
                                      // FutureBuilderForMenu(_searchListMenu[index]),
                                      FutureBuilder(
                                        future: _getMenuImage(_showListMenu[index]),
                                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                                          if (snapshot.data == null) {
                                            return Container(
                                              height: 150,
                                              width: MediaQuery.of(context).size.width,
                                              child: Card(
                                                  child: Icon(Icons.photo)
                                              ),
                                            );
                                          }else {
                                            /// Start for show picture by menu.
                                            List<dynamic>imageByMenu = [];
                                            for (var i in snapshot.data) {
                                              imageByMenu.add(i);
                                            }

                                            /// End.
                                            /// Start Slide_Image.
                                            return CarouselSlider(
                                              options: CarouselOptions(height: 150, autoPlay: true),
                                              items: imageByMenu.map((e) {
                                                return Builder(
                                                  builder: (BuildContext context) {
                                                    return Container(
                                                        height: 150,
                                                        width: MediaQuery.of(context).size.width,
                                                        child: Card(child: Image.memory(base64Decode(e), fit: BoxFit.fitWidth))
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
                                              _showListMenu[index].name,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  child: _showListMenu[index].priceMenuNormal == 0 /// if (price_Normal == 0)
                                                      ? null
                                                      : _showListMenu[index].priceMenuPromotion == 0 /// if
                                                      ? Text("ธรรมดา ${_showListMenu[index].priceMenuNormal.toString()} บาท", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold,),)
                                                      : Text("ธรรมดา ${_showListMenu[index].priceMenuNormal.toString()} บาท", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, decoration: TextDecoration.lineThrough,),),
                                                ),
                                                SizedBox(width: 25),
                                                Container(
                                                  child: _showListMenu[index].priceMenuSpecial == 0 /// if
                                                      ? null
                                                      : _showListMenu[index].priceMenuPromotion == 0 /// if
                                                      ? Text("พิเศษ ${_showListMenu[index].priceMenuSpecial.toString()} บาท", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold,),)
                                                      : Text("พิเศษ ${_showListMenu[index].priceMenuSpecial.toString()} บาท", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, decoration: TextDecoration.lineThrough,),),
                                                ),
                                                SizedBox(width: snapshot.data[index].priceMenuSpecial == 0 ? 105 : 25),
                                                Container(
                                                  child: _showListMenu[index].priceMenuPromotion == 0 /// if
                                                      ? null
                                                      : Text("โปรโมชั่น ${_showListMenu[index].priceMenuPromotion.toString()} บาท", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold,),),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                            ),
                          )
                              : Card( /// If => (false = หมด)
                              elevation: 5,
                              color: Colors.transparent,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  children: <Widget>[
                                    /// FutureBuilder
                                    // FutureBuilderForMenu(_searchListMenu[index]),
                                    FutureBuilder(
                                      future: _getMenuImage(_showListMenu[index]),
                                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                                        if (snapshot.data == null) {
                                          return Container(
                                            height: 150,
                                            width: MediaQuery.of(context).size.width,
                                            child: Card(
                                                child: Icon(Icons.photo)
                                            ),
                                          );
                                        } else {
                                          /// Start for show picture by menu.
                                          List<dynamic> imageByMenu = [];
                                          for (var i in snapshot.data) {
                                            imageByMenu.add(i);
                                          }

                                          /// End.
                                          /// Start Slide_Image.
                                          return CarouselSlider(
                                            options: CarouselOptions(height: 150, autoPlay: true),
                                            items: imageByMenu.map((e) {
                                              return Builder(
                                                builder: (BuildContext context) {
                                                  return Container(
                                                      height: 150,
                                                      width: MediaQuery.of(context).size.width,
                                                      child: Card(
                                                          child: Image.memory(base64Decode(e), fit: BoxFit.fitWidth,)
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
                                          child: Row(
                                            children: [
                                              Text(_showListMenu[index].name,style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,)),
                                              Text("[${_showListMenu[index].statusSale}]", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15,)),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: _showListMenu[index].priceMenuNormal == 0 /// if (price_Normal == 0)
                                                    ? null
                                                    : _showListMenu[index].priceMenuPromotion == 0 /// if
                                                    ? Text("ธรรมดา ${_showListMenu[index].priceMenuNormal.toString()} บาท", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold,),)
                                                    : Text("ธรรมดา ${_showListMenu[index].priceMenuNormal.toString()} บาท", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, decoration: TextDecoration.lineThrough,),),
                                              ),
                                              SizedBox(width: 25),
                                              Container(
                                                child: _showListMenu[index].priceMenuSpecial == 0 /// if
                                                    ? null
                                                    : _showListMenu[index].priceMenuPromotion == 0 /// if
                                                    ? Text("พิเศษ ${_showListMenu[index].priceMenuSpecial.toString()} บาท", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold,),)
                                                    : Text("พิเศษ ${_showListMenu[index].priceMenuSpecial.toString()} บาท", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, decoration: TextDecoration.lineThrough,),),
                                              ),
                                              SizedBox(width: snapshot.data[index].priceMenuSpecial == 0 ? 105 : 25),
                                              Container(
                                                child: _showListMenu[index].priceMenuPromotion == 0 /// if
                                                    ? null
                                                    : Text("โปรโมชั่น ${_showListMenu[index].priceMenuPromotion.toString()} บาท", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold,),),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                          )
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
      floatingActionButton: Container(
        child: FloatingActionButton(
          mini: true,
          backgroundColor: Colors.green.shade600,
          child: Icon(Icons.search),
          heroTag: "searchDrink",
          onPressed: () => _showListMenu.isEmpty
              ? ScaffoldMessenger.of(context).showSnackBar(
                new SnackBar(
                  content: Text("ไม่มีข้อมูลรายการ"),
                  duration: Duration(seconds: 1),
                )
              )
              : Navigator.push(context, CupertinoPageRoute(builder: (context) => SearchFoodDrink(_showListMenu))),
        ),
      ),
    );
  }
}