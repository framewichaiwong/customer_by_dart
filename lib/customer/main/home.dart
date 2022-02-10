import 'package:customer_by_dart/customer/class/class_user_manager.dart';
import 'package:customer_by_dart/customer/list/check_bill.dart';
import 'package:customer_by_dart/customer/list/tabbar/listmenu.dart';
import 'package:customer_by_dart/customer/list/res_information.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class Home extends StatefulWidget {
  int numberTable;
  List<UserManager> userManager;
  Home(this.userManager,this.numberTable);

  @override
  State<StatefulWidget> createState() => _Home(userManager,numberTable);
}

class _Home extends State<Home> {
  List<UserManager> userManager;
  int numberTable;
  _Home(this.userManager,this.numberTable);

  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {

    final _tabPage = <Widget>[
      ListMenu(userManager, numberTable),
      CheckBill(userManager, numberTable,),
      ResInformation(userManager),
    ];

    final _bottomNavigationBarItems = <BottomNavigationBarItem>[
      BottomNavigationBarItem(icon: Icon(Icons.format_list_numbered_rounded),label: "เมนู"),
      BottomNavigationBarItem(icon: Icon(Icons.request_quote_outlined),label: "ชำระเงิน"),
      BottomNavigationBarItem(icon: Icon(Icons.account_box_outlined),label: "ร้าน"),
    ];
    final bottomNavBar = BottomNavigationBar(
      items: _bottomNavigationBarItems,
      currentIndex: _currentTabIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (int index) {
        setState(() {
          _currentTabIndex = index;
        });
      },
    );

    // ignore: unrelated_type_equality_checks
    assert(_tabPage.length == _bottomNavigationBarItems.length);

    // TODO: implement build
    return Scaffold(
      body: _tabPage[_currentTabIndex],
      bottomNavigationBar: bottomNavBar,
    );
  }
}