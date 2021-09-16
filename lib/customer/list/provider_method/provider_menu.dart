import 'package:customer_by_dart/customer/class/class_menu_cart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MenuProvider extends ChangeNotifier {
  List<MenuCart> cart = [];

  void addMenuToCart(addMenu){
    cart.add(addMenu);
    notifyListeners();
  }

  void removeMenuTFromCart(removeMenu){
    cart.remove(removeMenu);
    notifyListeners();
  }

  void clearAllMenuFromCart(){
    cart.clear();
    notifyListeners();
  }

  //get getCartLength => this.cart.length;
}