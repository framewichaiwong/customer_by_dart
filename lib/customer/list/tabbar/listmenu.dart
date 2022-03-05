import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:customer_by_dart/customer/class/class_user_manager.dart';
import 'package:customer_by_dart/customer/list/provider_method/provider_menu.dart';
import 'package:customer_by_dart/customer/list/menu/type_drink.dart';
import 'package:customer_by_dart/customer/list/menu/type_food.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../cart/cart_menu.dart';

class ListMenu extends StatefulWidget {
  List<UserManager> userManager;
  int numberTable;
  ListMenu(this.userManager,this.numberTable);

  @override
  State<StatefulWidget> createState() => _ListMenu(userManager,numberTable);
}

class _ListMenu extends State<ListMenu> {
  List<UserManager> userManager;
  int numberTable;
  _ListMenu(this.userManager,this.numberTable);

  @override
  Widget build(BuildContext context) {

    final _tabPage = <Widget>[
      TypeFood(userManager,numberTable),
      TypeDrink(userManager,numberTable),
    ];
    final _tabBarItems = <Tab>[
      Tab(child: Text("อาหาร",style: TextStyle(fontSize: 20),),),
      Tab(child: Text("เครื่องดื่ม",style: TextStyle(fontSize: 20),),),
    ];

    return SafeArea(
      child: DefaultTabController(
        length: _tabPage.length,
        child: Scaffold(
          appBar: AppBar(
            // backgroundColor: Colors.red[300],
            backgroundColor: Colors.white60,
            shadowColor: Colors.blueGrey[300],
            title: Text("รายการอาหาร : " + "โต๊ะ " + "$numberTable",style: TextStyle(color: Colors.black),),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Badge(
                  badgeContent: Consumer<MenuProvider>(
                    builder: (BuildContext context, value, Widget? child) => Text("${value.cartMenu.length}"),
                  ),
                  badgeColor: Colors.lightBlueAccent,
                  animationType: BadgeAnimationType.slide,
                  position: BadgePosition.topEnd(top: 0,end: 0),
                  child: IconButton(
                    icon: Icon(Icons.shopping_cart_outlined,color: Colors.black),
                    iconSize: 35,
                    onPressed: () {
                      Navigator.push(context,CupertinoPageRoute(builder: (context) => CartMenu(userManager, numberTable)));
                    },
                  ),
                ),
              ),
            ],
            bottom: TabBar(
              tabs: _tabBarItems,
              // labelColor: Colors.white,
              // indicatorColor: Colors.blueGrey,
              // unselectedLabelColor: Colors.grey[500],
              labelColor: Colors.lightBlue,
              indicatorColor: Colors.lightBlue,
              unselectedLabelColor: Colors.grey[500],
            ),
          ),
          body: TabBarView(
            children: _tabPage,
          ),
        ),
      ),
    );
  }
}