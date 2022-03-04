import 'dart:convert';

import 'package:customer_by_dart/config/config.dart';
import 'package:customer_by_dart/customer/class/class_category_menu.dart';
import 'package:customer_by_dart/customer/class/class_menu.dart';
import 'package:customer_by_dart/customer/class/class_menu_cart.dart';
import 'package:customer_by_dart/customer/class/class_other_menu.dart';
import 'package:customer_by_dart/customer/list/provider_method/provider_menu.dart';
import 'package:customer_by_dart/customer/list/state/listview_other_menu_typefood_typedrink.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/src/provider.dart';

class SelectMenuToCart extends StatefulWidget {
  Menu showListMenu;
  SelectMenuToCart(this.showListMenu);


  @override
  _SelectMenuToCartState createState() => _SelectMenuToCartState(showListMenu);
}

class _SelectMenuToCartState extends State<SelectMenuToCart> {
  Menu showListMenu;
  _SelectMenuToCartState(this.showListMenu);

  int number = 1;
  int valRadio = 0;
  String? _nameMenu;
  int? _priceMenu;

  List<String> _showOtherStatus = [];
  List<String> _showOtherSelection = [];
  List<OtherMenu> _listOtherMenuSelect = [];
  List<OtherMenu> _listOtherMenuNotSelect = [];

  /// Add other_menu to cart.
  List<OtherMenu> _otherMenuCheckBox = [];
  List<OtherMenu> _otherMenuRadio = [];

  /// list (category_menu) AND (other_menu).
  Future _getCategoryAndOtherMenu() async {
    List<OtherMenu> listOtherMenu = [];
    List<OtherMenu> listOtherMenuSelect = [];
    List<OtherMenu> listOtherMenuNotSelect = [];
    List<CategoryMenu> listCategoryMenu = [];
    ///
    List<String> showOtherStatusBySelect = [];
    List<String> showOtherStatusByNotSelect = [];
    List<String> showOtherStatus = [];
    List<String> showOtherSelection = [];///
    _showOtherSelection = [];///

    /// Call api (category_menu).
    var responseCategoryMenu = await http.get(Uri.parse("${Config.url}/categoryMenu/list/${showListMenu.managerId}/${showListMenu.categoryName}"), headers: {'Accept': 'Application/json; charset=UTF-8'});
    var jsonDataCategoryMenu = jsonDecode(responseCategoryMenu.body);
    var dataCategoryMenu = jsonDataCategoryMenu['data'];
    for (Map c in dataCategoryMenu) {
      CategoryMenu list = new CategoryMenu(c['categoryMenuId'], c['categoryMenuName'], c['otherMenuId'], c['managerId']);
      listCategoryMenu.add(list);

      /// Call api (other_menu).
      var responseOtherMenu = await http.get(Uri.parse('${Config.url}/otherMenu/list/${list.otherMenuId}'), headers: {'Accept': 'Application/json; charset=UTF-8'});
      var jsonDataOtherMenu = jsonDecode(responseOtherMenu.body);
      var dataOtherMenu = jsonDataOtherMenu['data'];
      OtherMenu otherMenu = new OtherMenu(dataOtherMenu['otherMenuId'], dataOtherMenu['otherMenuName'], dataOtherMenu['otherMenuPrice'], dataOtherMenu['otherSelection'], dataOtherMenu['otherStatus'], dataOtherMenu['otherStatusSale'], dataOtherMenu['managerId'], dataOtherMenu['typeMenu']);
      listOtherMenu.add(otherMenu);
      showOtherSelection.add(dataOtherMenu['otherSelection']);///

      if(dataOtherMenu['otherSelection'] == "เลือก"){
        OtherMenu otherMenu = new OtherMenu(dataOtherMenu['otherMenuId'], dataOtherMenu['otherMenuName'], dataOtherMenu['otherMenuPrice'], dataOtherMenu['otherSelection'], dataOtherMenu['otherStatus'], dataOtherMenu['otherStatusSale'], dataOtherMenu['managerId'], dataOtherMenu['typeMenu']);
        listOtherMenuSelect.add(otherMenu);
        showOtherStatusBySelect.add(dataOtherMenu['otherStatus']);
      }else{
        OtherMenu otherMenu = new OtherMenu(dataOtherMenu['otherMenuId'], dataOtherMenu['otherMenuName'], dataOtherMenu['otherMenuPrice'], dataOtherMenu['otherSelection'], dataOtherMenu['otherStatus'], dataOtherMenu['otherStatusSale'], dataOtherMenu['managerId'], dataOtherMenu['typeMenu']);
        listOtherMenuNotSelect.add(otherMenu);
        showOtherStatusByNotSelect.add("A-Z" + dataOtherMenu['otherStatus']); /// ใส่ตัวอักษรเพื่อตรวจสอบค่าของการแสดงเมนูเพิ่มเติม.
      }
      _showOtherSelection = showOtherSelection.toSet().toList();///
    }
    _listOtherMenuSelect = listOtherMenuSelect;
    _listOtherMenuNotSelect = listOtherMenuNotSelect;

    showOtherStatusBySelect.toSet().toList();
    for(int i=0; i<showOtherStatusBySelect.length; i++){
      showOtherStatus.add(showOtherStatusBySelect[i]);
    }
    showOtherStatusByNotSelect.toSet().toList();
    for(int i=0; i<showOtherStatusByNotSelect.length; i++){
      showOtherStatus.add(showOtherStatusByNotSelect[i]);
    }
    _showOtherStatus = showOtherStatus.toSet().toList();
    return listOtherMenu;
  }

  /// Button select_menu.
  _buttonSelectMenu(Menu menu) {
    if(valRadio == 0){ /// ().
      valRadio = 0;
    }else{ /// ().
      if(_showOtherSelection.isEmpty || _showOtherSelection.length==0){ /// ().
        String forCheckName = _nameMenu!;
        MenuCart lst = new MenuCart(menu.menuId, _nameMenu!, _priceMenu!, menu.typeMenu, menu.managerId, number, []);
        /// Add cart menu by Provider.
        context.read<MenuProvider>().addMenuToCart(lst,forCheckName);
        ScaffoldMessenger.of(context).showSnackBar(
          new SnackBar(
            content: Text("เพิ่ม ${menu.name} จำนวน $number" + " ไปยังตะกร้าของคุณ"),
            duration: Duration(seconds: 1),
          ),
        );
        number = 1;
        valRadio = 0;
        Navigator.pop(context);
      }else{ /// ().
        if(_showOtherSelection.contains("เลือก") && _showOtherSelection.contains("ไม่เลือก")){ /// ().
          if(_otherMenuRadio.isNotEmpty && _otherMenuCheckBox.isEmpty){
            String forCheckName = _nameMenu!;
            MenuCart lst = new MenuCart(menu.menuId, _nameMenu!, _priceMenu!, menu.typeMenu, menu.managerId, number, _otherMenuRadio);
            _otherMenuRadio.forEach((e) {
              forCheckName += "+${e.otherMenuName}";
            });
            /// Add cart menu by Provider.
            context.read<MenuProvider>().addMenuToCart(lst,forCheckName);
            ScaffoldMessenger.of(context).showSnackBar(
              new SnackBar(
                content: Text("เพิ่ม ${menu.name} จำนวน $number" + " ไปยังตะกร้าของคุณ"),
                duration: Duration(seconds: 1),
              ),
            );
            number = 1;
            valRadio = 0;
            _otherMenuRadio = [];
            Navigator.pop(context);
          }else if(_otherMenuRadio.isNotEmpty && _otherMenuCheckBox.isNotEmpty){
            String forCheckName = _nameMenu!;
            List<OtherMenu> _otherMenuByRadioAndCheckBox = [];
            for(int i=0; i<_otherMenuRadio.length; i++){
              _otherMenuByRadioAndCheckBox.add(_otherMenuRadio[i]);
            }
            for(int i=0; i<_otherMenuCheckBox.length; i++){
              _otherMenuByRadioAndCheckBox.add(_otherMenuCheckBox[i]);
            }
            MenuCart lst = new MenuCart(menu.menuId, _nameMenu!, _priceMenu!, menu.typeMenu, menu.managerId, number, _otherMenuByRadioAndCheckBox);
            _otherMenuByRadioAndCheckBox.forEach((e) {
              forCheckName += "+${e.otherMenuName}";
            });
            /// Add cart menu by Provider.
            context.read<MenuProvider>().addMenuToCart(lst,forCheckName);
            ScaffoldMessenger.of(context).showSnackBar(
              new SnackBar(
                content: Text("เพิ่ม ${menu.name} จำนวน $number" + " ไปยังตะกร้าของคุณ"),
                duration: Duration(seconds: 1),
              ),
            );
            number = 1;
            valRadio = 0;
            _otherMenuRadio = [];
            _otherMenuCheckBox = [];
            Navigator.pop(context);
          }
        }else if(_showOtherSelection.contains("เลือก")){ /// ().
          if(_otherMenuRadio.isNotEmpty){ /// ().
            String forCheckName = _nameMenu!;
            MenuCart lst = new MenuCart(menu.menuId, _nameMenu!, _priceMenu!, menu.typeMenu, menu.managerId, number, _otherMenuRadio);
            _otherMenuRadio.forEach((e) {
              forCheckName += "+${e.otherMenuName}";
            });
            /// Add cart menu by Provider.
            context.read<MenuProvider>().addMenuToCart(lst,forCheckName);
            ScaffoldMessenger.of(context).showSnackBar(
              new SnackBar(
                content: Text("เพิ่ม ${menu.name} จำนวน $number" + " ไปยังตะกร้าของคุณ"),
                duration: Duration(seconds: 1),
              ),
            );
            number = 1;
            valRadio = 0;
            _otherMenuRadio = [];
            Navigator.pop(context);
          }
        }else if(_showOtherSelection.contains("ไม่เลือก")){ /// ().
          if(_otherMenuCheckBox.isEmpty){
            String forCheckName = _nameMenu!;
            MenuCart lst = new MenuCart(menu.menuId, _nameMenu!, _priceMenu!, menu.typeMenu, menu.managerId, number, []);
            /// Add cart menu by Provider.
            context.read<MenuProvider>().addMenuToCart(lst,forCheckName);
            ScaffoldMessenger.of(context).showSnackBar(
              new SnackBar(
                content: Text("เพิ่ม ${menu.name} จำนวน $number" + " ไปยังตะกร้าของคุณ"),
                duration: Duration(seconds: 1),
              ),
            );
            number = 1;
            valRadio = 0;
            Navigator.pop(context);
          }else if(_otherMenuCheckBox.isNotEmpty){
            String forCheckName = _nameMenu!;
            MenuCart lst = new MenuCart(menu.menuId, _nameMenu!, _priceMenu!, menu.typeMenu, menu.managerId, number, _otherMenuCheckBox);
            _otherMenuCheckBox.forEach((e) {
              forCheckName += "+${e.otherMenuName}";
            });
            /// Add cart menu by Provider.
            context.read<MenuProvider>().addMenuToCart(lst,forCheckName);
            ScaffoldMessenger.of(context).showSnackBar(
              new SnackBar(
                content: Text("เพิ่ม ${menu.name} จำนวน $number" + " ไปยังตะกร้าของคุณ"),
                duration: Duration(seconds: 1),
              ),
            );
            number = 1;
            valRadio = 0;
            _otherMenuCheckBox = [];
            Navigator.pop(context);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                  children: [
                      Divider(
                      thickness: 2,
                        color: Colors.black,
                      ),
                      Text("${showListMenu.name}",style: TextStyle(fontSize: 18)),
                      Divider(
                        thickness: 2,
                        color: Colors.black,
                      ),
                      /// Special or Normal or Promotion.
                      Center(
                        child: showListMenu.priceMenuPromotion == 0 /// if
                            ? Column( ///true
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(
                                    child: valRadio == 0
                                        ? Text("*กรุณาเลือก พิเศษ หรือ ธรรมดา", style: TextStyle(color: Colors.redAccent),)
                                        : Text("กรุณาเลือก พิเศษ หรือ ธรรมดา"),
                                  ),
                                  Center(
                                    child: showListMenu.priceMenuNormal == 0
                                        ? null
                                        : Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Radio(
                                          value: 1,
                                          groupValue: valRadio,
                                          onChanged: (int? value0) {
                                            setState(() {
                                              valRadio = value0!;
                                              _nameMenu = "${showListMenu.name} (ธรรมดา)";
                                              _priceMenu = showListMenu.priceMenuNormal;
                                            });
                                          },
                                        ),
                                        Expanded(
                                          child: Text("ธรรมดา"),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Center(
                                    child: showListMenu.priceMenuSpecial == 0
                                        ? null
                                        : Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Radio(
                                          value: 2,
                                          groupValue: valRadio,
                                          onChanged: (int? value1) {
                                            setState(() {
                                              valRadio = value1!;
                                              _nameMenu = "${showListMenu.name} (พิเศษ)";
                                              _priceMenu =  showListMenu.priceMenuSpecial;
                                            });
                                          },
                                        ),
                                        Expanded(
                                          child: Text("พิเศษ"),
                                        ),
                                      ],
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
                                    child: showListMenu.priceMenuNormal == 0
                                        ? null
                                        : Row(
                                      children: [
                                        Radio(
                                          value: 1,
                                          groupValue: valRadio,
                                          onChanged: (int? value0) {
                                            setState(() {
                                              valRadio = value0!;
                                              _nameMenu = "${showListMenu.name} (โปรโมชั่น)";
                                              _priceMenu = showListMenu.priceMenuPromotion;
                                            });
                                          },
                                        ),
                                        Expanded(
                                          child: Text("โปรโมชั่น"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      FutureBuilder(
                          future: _getCategoryAndOtherMenu(),
                          builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.data == null || snapshot.data.length == 0) {
                              return Center(
                                // child: CircularProgressIndicator(),
                                child: null,
                              );
                            }else {
                              return ListViewForOtherMenu(
                                _listOtherMenuNotSelect,
                                _listOtherMenuSelect,
                                _showOtherStatus,
                                    (addOtherMenu) => setState(() => _otherMenuCheckBox.add(addOtherMenu)),
                                    (removeOtherMenu) => setState(() => _otherMenuCheckBox.remove(removeOtherMenu)),
                                    (selectOtherMenu) => setState(() {
                                  _otherMenuRadio = [];
                                  for(int i=0; i<selectOtherMenu.length; i++){
                                    _otherMenuRadio.add(selectOtherMenu[i]);
                                  }
                                }),
                              );
                            }
                          }
                      ),
                      SizedBox(height: 25),
                      /// Icon_Button add number.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                      ),
                  ],
              ),
            )
        ),
      ),
      bottomSheet: Container(
        color: Colors.grey[200],
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10,right: 10),
              child: Center(
                child: Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                    ),
                    child: Text("เพิ่มไปยังตะกร้า"),
                    onPressed: () => _buttonSelectMenu(showListMenu),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10,right: 10),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red[300],
                    ),
                    child: Text("ย้อนกลับ"),
                    onPressed: () {
                      number = 1;
                      valRadio = 0;
                      _otherMenuCheckBox = [];
                      _otherMenuRadio = [];
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
