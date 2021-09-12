import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:customer_by_dart/customer/class/class_menu_cart.dart';
import 'package:customer_by_dart/customer/class/class_user_manager.dart';
import 'package:customer_by_dart/customer/list/type_drink.dart';
import 'package:customer_by_dart/customer/list/type_food.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'cart_menu.dart';

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

  List<MenuCart> _cart = [];

  @override
  Widget build(BuildContext context) {

    final _tabPage = <Widget>[
      TypeFood(
          userManager,
          numberTable,
              (addMenu){
            setState(() {
              _cart.add(addMenu);
            });
          }
      ),
      TypeDrink(
          userManager,
          numberTable,
              (addMenu) {
            setState(() {
              _cart.add(addMenu);
            });
          }
      ),
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
            backgroundColor: Colors.red[300],
            title: Text("รายการอาหาร : " + "โต๊ะ " + "$numberTable"),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Badge(
                  badgeContent: Text("${_cart.length}",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
                  badgeColor: Colors.lightBlueAccent,
                  animationType: BadgeAnimationType.slide,
                  position: BadgePosition.topEnd(top: 0,end: 0),
                  child: IconButton(
                    icon: Icon(Icons.shopping_cart_outlined),
                    iconSize: 35,
                    onPressed: () {
                      Navigator.push(context,MaterialPageRoute(builder: (context) => CartMenu(userManager, numberTable, _cart,
                              (removeMenu){setState(() {
                            if(removeMenu == null){ /// get value from Page(cart_menu) after press the button(สั่งอาหาร).
                              //_cart.removeRange(0, _cart.length);/// reset value in (_cart) Arrays at start[0] to end[...length]
                              _cart.clear(); /// reset value in _cart.
                            }else{ /// get value from Page(cart_menu) after press the icon(X).
                              _cart.remove(removeMenu);
                            }
                          });
                          })));
                    },
                  ),
                ),
              ),
            ],
            bottom: TabBar(
              tabs: _tabBarItems,
              labelColor: Colors.white,
              indicatorColor: Colors.blueGrey,
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